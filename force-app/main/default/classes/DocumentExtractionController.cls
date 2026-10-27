public with sharing class DocumentExtractionController {

    private static final String PROMPT_TEMPLATE_API_NAME = 'Document_Extraction';
    private static final Set<String> SUPPORTED_EXTENSIONS = new Set<String>{
        'pdf', 'png', 'jpg', 'jpeg', 'txt', 'csv', 'gif', 'webp', 'tif', 'tiff'
    };

    public class RecentFileDTO {
        @AuraEnabled public String documentId;
        @AuraEnabled public String versionId;
        @AuraEnabled public String title;
        @AuraEnabled public String fileExtension;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public String relativeTime;
        @AuraEnabled public String iconName;
    }

    public class FilePreviewDTO {
        @AuraEnabled public String documentId;
        @AuraEnabled public String versionId;
        @AuraEnabled public String title;
        @AuraEnabled public String fileExtension;
        @AuraEnabled public Boolean isImage;
        @AuraEnabled public Boolean isPdf;
        @AuraEnabled public Boolean hasInlinePreview;
        @AuraEnabled public String previewUrl;
        @AuraEnabled public String downloadUrl;
        @AuraEnabled public String mimeType;
    }

    @AuraEnabled(cacheable=true)
    public static List<RecentFileDTO> getRecentUploads() {
        List<ContentVersion> versions = [
            SELECT Id, ContentDocumentId, Title, FileExtension, CreatedDate
            FROM ContentVersion
            WHERE IsLatest = true
              AND CreatedById = :UserInfo.getUserId()
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];

        List<RecentFileDTO> results = new List<RecentFileDTO>();
        for (ContentVersion cv : versions) {
            RecentFileDTO dto = new RecentFileDTO();
            dto.documentId = cv.ContentDocumentId;
            dto.versionId = cv.Id;
            dto.title = cv.Title;
            dto.fileExtension = cv.FileExtension;
            dto.createdDate = cv.CreatedDate;
            dto.relativeTime = toRelativeTime(cv.CreatedDate);
            dto.iconName = toIconName(cv.FileExtension);
            results.add(dto);
        }
        return results;
    }

    // Inline preview via base64 (shepherd/rendition URLs often render blank inside LWC).
    private static final Integer MAX_INLINE_PREVIEW_BYTES = 3500000;

    @AuraEnabled
    public static FilePreviewDTO getFilePreview(String documentId) {
        if (String.isBlank(documentId)) {
            throw new AuraHandledException('Document Id is required.');
        }

        ContentVersion meta = [
            SELECT Id, ContentDocumentId, Title, FileExtension, ContentSize
            FROM ContentVersion
            WHERE ContentDocumentId = :documentId
              AND IsLatest = true
            LIMIT 1
        ];

        String ext = meta.FileExtension == null ? '' : meta.FileExtension.toLowerCase();
        FilePreviewDTO dto = new FilePreviewDTO();
        dto.documentId = meta.ContentDocumentId;
        dto.versionId = meta.Id;
        dto.title = meta.Title;
        dto.fileExtension = ext;
        dto.isImage = new Set<String>{ 'png', 'jpg', 'jpeg', 'gif', 'webp', 'tif', 'tiff' }.contains(ext);
        dto.isPdf = ext == 'pdf';
        dto.mimeType = toMimeType(ext);
        dto.downloadUrl = '/sfc/servlet.shepherd/version/download/' + meta.Id;
        dto.hasInlinePreview = false;
        dto.previewUrl = dto.downloadUrl;

        Boolean canInline =
            (dto.isImage || dto.isPdf) &&
            meta.ContentSize != null &&
            meta.ContentSize <= MAX_INLINE_PREVIEW_BYTES;

        if (canInline) {
            ContentVersion blobRow = [
                SELECT VersionData
                FROM ContentVersion
                WHERE Id = :meta.Id
                LIMIT 1
            ];
            dto.previewUrl =
                'data:' +
                dto.mimeType +
                ';base64,' +
                EncodingUtil.base64Encode(blobRow.VersionData);
            dto.hasInlinePreview = true;
        }

        return dto;
    }

    private static String toMimeType(String ext) {
        if (ext == 'png') return 'image/png';
        if (ext == 'jpg' || ext == 'jpeg') return 'image/jpeg';
        if (ext == 'gif') return 'image/gif';
        if (ext == 'webp') return 'image/webp';
        if (ext == 'tif' || ext == 'tiff') return 'image/tiff';
        if (ext == 'pdf') return 'application/pdf';
        if (ext == 'txt') return 'text/plain';
        if (ext == 'csv') return 'text/csv';
        return 'application/octet-stream';
    }

    @AuraEnabled
    public static String extractDataFromDocument(String documentId) {
        try {
            if (String.isBlank(documentId)) {
                throw new AuraHandledException('Document Id is required.');
            }

            ContentVersion cv = [
                SELECT Id, Title, FileExtension, ContentSize, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId = :documentId
                  AND IsLatest = true
                LIMIT 1
            ];

            String ext = cv.FileExtension == null ? '' : cv.FileExtension.toLowerCase();
            if (String.isNotBlank(ext) && !SUPPORTED_EXTENSIONS.contains(ext)) {
                throw new AuraHandledException(
                    'Unsupported file type ".' + ext +
                    '". Upload a PDF, image (PNG/JPG/TIFF), TXT, or CSV.'
                );
            }

            Map<String, String> fileData = new Map<String, String>{
                'id' => documentId,
                'type' => 'ContentDocument'
            };

            ConnectApi.WrappedValue fileInput = new ConnectApi.WrappedValue();
            fileInput.value = fileData;

            Map<String, ConnectApi.WrappedValue> inputParams =
                new Map<String, ConnectApi.WrappedValue>();
            inputParams.put('Input:documentText', fileInput);

            ConnectApi.EinsteinPromptTemplateGenerationsInput promptInput =
                new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            promptInput.inputParams = inputParams;
            promptInput.isPreview = false;
            promptInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            promptInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';

            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation response =
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                    PROMPT_TEMPLATE_API_NAME,
                    promptInput
                );

            if (response == null || response.generations == null || response.generations.isEmpty()) {
                throw new AuraHandledException('No extraction response returned from the prompt template.');
            }

            String text = response.generations[0].text;
            if (String.isBlank(text)) {
                throw new AuraHandledException('The prompt template returned an empty response.');
            }
            return text;
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Error extracting data: ' + e.getMessage());
        }
    }

    private static String toRelativeTime(Datetime createdDate) {
        if (createdDate == null) {
            return '';
        }
        Long minutes = Math.max(0, (Datetime.now().getTime() - createdDate.getTime()) / 60000);
        if (minutes < 1) {
            return 'Just now';
        }
        if (minutes < 60) {
            return String.valueOf(minutes) + ' minute' + (minutes == 1 ? '' : 's') + ' ago';
        }
        Long hours = minutes / 60;
        if (hours < 24) {
            return String.valueOf(hours) + ' hour' + (hours == 1 ? '' : 's') + ' ago';
        }
        Long days = hours / 24;
        return String.valueOf(days) + ' day' + (days == 1 ? '' : 's') + ' ago';
    }

    private static String toIconName(String fileExtension) {
        String ext = fileExtension == null ? '' : fileExtension.toLowerCase();
        if (ext == 'pdf') {
            return 'doctype:pdf';
        }
        if (ext == 'png' || ext == 'jpg' || ext == 'jpeg' || ext == 'gif' || ext == 'webp' || ext == 'tif' || ext == 'tiff') {
            return 'doctype:image';
        }
        if (ext == 'csv') {
            return 'doctype:csv';
        }
        if (ext == 'txt') {
            return 'doctype:txt';
        }
        return 'doctype:unknown';
    }
}