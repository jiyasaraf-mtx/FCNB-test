import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';
import extractDataFromDocument from '@salesforce/apex/DocumentExtractionController.extractDataFromDocument';
import getRecentUploads from '@salesforce/apex/DocumentExtractionController.getRecentUploads';
import getFilePreview from '@salesforce/apex/DocumentExtractionController.getFilePreview';

const CONTENT_DOCUMENT_HOME =
    'https://lpi-psf-core--widpi.sandbox.lightning.force.com/lightning/o/ContentDocument/home';

export default class DocumentExtractionLwc extends LightningElement {
    userId = USER_ID;
    acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg', '.tif', '.tiff', '.txt', '.csv'];

    @track isLoading = false;
    @track isLoadingPreview = false;
    @track sections = [];
    @track tables = [];
    @track hasData = false;
    @track recentFiles = [];
    @track preview = null;
    @track selectedDocumentId;
    @track processedIds = [];
    @track zoomPercent = 100;

    recentUploadsWire;

    @wire(getRecentUploads)
    wiredRecentUploads(result) {
        this.recentUploadsWire = result;
        const { data, error } = result;
        if (data) {
            this.recentFiles = data.map((file) => this.decorateRecentFile(file));
        } else if (error) {
            // eslint-disable-next-line no-console
            console.error(error);
        }
    }

    get hasRecentFiles() {
        return this.recentFiles && this.recentFiles.length > 0;
    }

    get hasPreview() {
        return !!this.preview;
    }

    get showImagePreview() {
        return this.preview && this.preview.isImage && this.preview.hasInlinePreview;
    }

    get showPdfPreview() {
        return this.preview && this.preview.isPdf && this.preview.hasInlinePreview;
    }

    get showPreviewFallback() {
        return (
            this.preview &&
            (!this.preview.hasInlinePreview || (!this.preview.isImage && !this.preview.isPdf))
        );
    }

    get isOtherFile() {
        return this.preview && !this.preview.isImage && !this.preview.isPdf;
    }

    get hasSections() {
        return this.sections && this.sections.length > 0;
    }

    get hasTables() {
        return this.tables && this.tables.length > 0;
    }

    get showExtracted() {
        return this.hasData && !this.isLoading;
    }

    get activeSectionNames() {
        return (this.sections || []).map((section) => section.title);
    }

    get zoomLabel() {
        return `${this.zoomPercent}%`;
    }

    get imageZoomStyle() {
        return `width: ${this.zoomPercent}%; max-width: none;`;
    }

    decorateRecentFile(file) {
        const isProcessed = this.processedIds.includes(file.documentId);
        const isSelected = this.selectedDocumentId === file.documentId;
        return {
            ...file,
            itemClass: isSelected ? 'recent-item-active' : 'recent-item',
            statusClass: isProcessed ? 'status-ok' : 'status-idle',
            statusIcon: isProcessed ? 'utility:success' : 'utility:clock',
            statusLabel: isProcessed ? 'Processed' : 'Ready'
        };
    }

    refreshRecentDecorators() {
        this.recentFiles = (this.recentFiles || []).map((file) => this.decorateRecentFile(file));
    }

    handleViewAll() {
        // Exact Files home URL requested by user
        window.open(CONTENT_DOCUMENT_HOME, '_blank');
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files || [];
        if (uploadedFiles.length === 0) {
            return;
        }
        const documentId = uploadedFiles[0].documentId;
        this.selectAndProcess(documentId, true);
        refreshApex(this.recentUploadsWire);
    }

    handleRecentFileClick(event) {
        const documentId = event.currentTarget.dataset.id;
        if (!documentId) {
            return;
        }
        this.selectAndProcess(documentId, true);
    }

    selectAndProcess(documentId, runExtraction) {
        this.selectedDocumentId = documentId;
        this.refreshRecentDecorators();
        this.loadPreview(documentId);
        if (runExtraction) {
            this.processFile(documentId);
        }
    }

    loadPreview(documentId) {
        this.isLoadingPreview = true;
        this.preview = null;
        this.zoomPercent = 100;

        getFilePreview({ documentId })
            .then((result) => {
                this.preview = result;
                this.isLoadingPreview = false;
            })
            .catch((error) => {
                this.isLoadingPreview = false;
                this.showToast(
                    'Preview Error',
                    error.body ? error.body.message : error.message,
                    'error'
                );
            });
    }

    processFile(documentId) {
        this.isLoading = true;
        this.hasData = false;
        this.sections = [];
        this.tables = [];

        extractDataFromDocument({ documentId })
            .then((result) => {
                this.parseJsonResult(result);
                if (!this.processedIds.includes(documentId)) {
                    this.processedIds = [...this.processedIds, documentId];
                }
                this.refreshRecentDecorators();
                this.isLoading = false;
                this.showToast(
                    'Success',
                    'Document processed successfully. Information extracted. Please review and confirm.',
                    'success'
                );
            })
            .catch((error) => {
                this.isLoading = false;
                this.showToast(
                    'Error',
                    error.body ? error.body.message : error.message,
                    'error'
                );
            });
    }

    zoomIn() {
        this.zoomPercent = Math.min(200, this.zoomPercent + 10);
    }

    zoomOut() {
        this.zoomPercent = Math.max(50, this.zoomPercent - 10);
    }

    parseJsonResult(jsonString) {
        try {
            const cleanString = String(jsonString || '')
                .replace(/```json/gi, '')
                .replace(/```/g, '')
                .trim();
            const parsedData = JSON.parse(cleanString);

            if (parsedData === null || typeof parsedData !== 'object') {
                this.sections = [
                    {
                        title: 'Extracted Value',
                        fields: [{ key: 'Value', value: this.formatPrimitive(parsedData) }]
                    }
                ];
                this.tables = [];
                this.hasData = true;
                return;
            }

            const { sections, tables } = this.buildDisplayModel(parsedData);
            this.sections = sections;
            this.tables = tables;
            this.hasData = sections.length > 0 || tables.length > 0;

            if (!this.hasData) {
                this.showToast('No Data', 'AI returned an empty extraction result.', 'warning');
            }
        } catch (e) {
            // eslint-disable-next-line no-console
            console.error('Error parsing JSON from Einstein:', e, jsonString);
            this.showToast(
                'Extraction Error',
                'Could not parse the AI response correctly.',
                'error'
            );
        }
    }

    buildDisplayModel(parsedData) {
        const sections = [];
        const tables = [];

        if (Array.isArray(parsedData)) {
            const normalized = this.normalizeToObjectArray(parsedData);
            if (normalized) {
                tables.push(this.toTable('Results', normalized));
            } else {
                sections.push({
                    title: 'Results',
                    fields: [{ key: 'Values', value: this.formatPrimitive(parsedData) }]
                });
            }
            return { sections, tables };
        }

        const rootFields = [];

        Object.keys(parsedData).forEach((key) => {
            this.collectNode(parsedData[key], this.toLabel(key), rootFields, tables, sections);
        });

        if (rootFields.length > 0) {
            sections.unshift({
                title: 'Summary',
                fields: rootFields
            });
        }

        return { sections, tables };
    }

    collectNode(value, label, fields, tables, sections) {
        const resolved = this.tryParseJsonString(value);

        if (Array.isArray(resolved)) {
            const objectRows = this.normalizeToObjectArray(resolved);
            if (objectRows) {
                tables.push(this.toTable(label, objectRows));
                return;
            }
            fields.push({
                key: label,
                value: this.formatPrimitive(resolved)
            });
            return;
        }

        if (resolved !== null && typeof resolved === 'object') {
            const nestedFields = [];
            Object.keys(resolved).forEach((childKey) => {
                this.collectNode(
                    resolved[childKey],
                    this.toLabel(childKey),
                    nestedFields,
                    tables,
                    sections
                );
            });

            if (nestedFields.length > 0) {
                sections.push({
                    title: label,
                    fields: nestedFields
                });
            }
            return;
        }

        fields.push({
            key: label,
            value: this.formatPrimitive(resolved)
        });
    }

    tryParseJsonString(value) {
        if (typeof value !== 'string') {
            return value;
        }
        const trimmed = value.trim();
        if (
            !(
                (trimmed.startsWith('[') && trimmed.endsWith(']')) ||
                (trimmed.startsWith('{') && trimmed.endsWith('}'))
            )
        ) {
            return value;
        }
        try {
            return JSON.parse(trimmed);
        } catch (e) {
            return value;
        }
    }

    normalizeToObjectArray(arr) {
        if (!Array.isArray(arr) || arr.length === 0) {
            return null;
        }

        const resolved = arr.map((item) => this.tryParseJsonString(item));
        const allObjects = resolved.every(
            (item) => item !== null && typeof item === 'object' && !Array.isArray(item)
        );
        if (!allObjects) {
            return null;
        }
        return resolved;
    }

    toTable(tableName, rows) {
        const normalizedRows = rows.map((row, index) => {
            const flat = { id: `${tableName}-${index}` };
            Object.keys(row || {}).forEach((colKey) => {
                const cell = this.tryParseJsonString(row[colKey]);
                if (cell !== null && typeof cell === 'object') {
                    flat[colKey] = Array.isArray(cell)
                        ? cell
                              .map((v) => this.formatPrimitive(v))
                              .filter((v) => v !== '')
                              .join(', ')
                        : Object.keys(cell)
                              .map((k) => `${this.toLabel(k)}: ${this.formatPrimitive(cell[k])}`)
                              .join('; ');
                } else {
                    flat[colKey] = this.formatPrimitive(cell);
                }
            });
            return flat;
        });

        const columnKeys = new Set();
        normalizedRows.forEach((row) => {
            Object.keys(row).forEach((k) => {
                if (k !== 'id') {
                    columnKeys.add(k);
                }
            });
        });

        const columns = Array.from(columnKeys).map((colKey) => ({
            label: this.toLabel(colKey),
            fieldName: colKey,
            type: 'text',
            wrapText: true
        }));

        const name = String(tableName || 'Table').toUpperCase();
        return {
            key: `${name}-${normalizedRows.length}-${columns.length}-${Math.random()
                .toString(36)
                .slice(2, 8)}`,
            tableName: name,
            columns,
            data: normalizedRows
        };
    }

    toLabel(key) {
        return String(key)
            .replace(/_/g, ' ')
            .replace(/([a-z])([A-Z])/g, '$1 $2')
            .trim();
    }

    formatPrimitive(value) {
        if (value === null || value === undefined) {
            return '';
        }
        if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') {
            return String(value);
        }
        if (Array.isArray(value)) {
            if (value.length === 0) {
                return '';
            }
            return value.map((item) => this.formatPrimitive(item)).join(', ');
        }
        if (typeof value === 'object') {
            return Object.keys(value)
                .map((k) => `${this.toLabel(k)}: ${this.formatPrimitive(value[k])}`)
                .join('; ');
        }
        return String(value);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}