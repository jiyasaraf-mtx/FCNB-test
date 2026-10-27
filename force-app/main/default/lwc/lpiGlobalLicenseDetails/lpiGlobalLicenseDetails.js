import { LightningElement,wire } from 'lwc';
import lpiResource from '@salesforce/resourceUrl/LPI_Design';
import { CurrentPageReference } from 'lightning/navigation';
export default class LpiGlobalLicenseDetails extends LightningElement {
    norecords = lpiResource + '/media/icons/norecords.svg';
    title;
    description;
    licenseId;
    selectedData;

   licenseDetailsMap = {
        '1': {
            processingTime: '3-5 business days',
            overview: 'The FCNB Individual Insurance Agent Licence authorizes qualified, sponsored individuals to legally conduct Life, General, Accident & Sickness, or Travel insurance business in New Brunswick.',
            linkUrl: 'https://www.fcnb.ca/',
            linkText: 'Financial and Consumer Services Commission Insurance Regulations',
            whoTitle: 'Who should apply for an Insurance Agent License?',
            whoSub: 'This pathway is for individuals who:',
            whoList: [
                'Are sponsored by a licensed insurance company operating in New Brunswick.',
                'Have passed the Life License Qualification Program (LLQP) or relevant general insurance exams.',
                'Meet provincial ethical and background compliance standards.'
            ],
            requirements: [
                'Proof of employment or sponsorship from an authorized insurance company.',
                'Successful completion of required qualification exams (LLQP / CIP).',
                'Background check and criminal record disclosure.',
                'Submission of completed online application and licensing fees.'
            ],
            howToApply: [
                'Obtain sponsorship from an authorized insurance provider.',
                'Complete mandatory qualification examinations.',
                'Submit your application through the portal.',
                'Pay the applicable regulatory fees.'
            ],
            fees: [
                { type: 'Agent Application Fee', refundable: 'No', amount: '$ 100.00', comments: 'Initial processing fee' },
                { type: 'Annual License Fee', refundable: 'No', amount: '$ 75.00', comments: 'Yearly registration maintenance' }
            ],
            duration: {
                processing: '3-5 business days',
                term: '1 Year (Annual Renewal)',
                renewable: 'Yes',
                requirements: 'Annual renewal and active company sponsorship'
            },
            additionalInfo: 'Insurance agents must maintain valid errors and omissions (E&O) insurance coverage throughout the duration of their licensure.'
        },
        '2': {
            processingTime: '5-7 business days',
            overview: 'The Real Estate Salesperson License enables qualified individuals to represent buyers and sellers in real estate transactions within New Brunswick.',
            linkUrl: 'https://www.fcnb.ca/',
            linkText: 'Real Estate Trading Act Regulations',
            whoTitle: 'Who should apply for a Real Estate License?',
            whoSub: 'This pathway is for individuals who:',
            whoList: [
                'Have completed the required pre-licensing real estate courses.',
                'Are registered or sponsored by a licensed Real Estate Brokerage in NB.'
            ],
            requirements: [
                'Completion of New Brunswick Pre-Licensing Education Program.',
                'Sponsorship letter from a licensed broker.',
                'Clear Police Record Check with Vulnerable Sector Screening.'
            ],
            howToApply: [
                'Complete required pre-licensing education modules.',
                'Secure employment/sponsorship with a licensed real estate brokerage.',
                'Submit application along with proof of education and background check.'
            ],
            fees: [
                { type: 'Standard', refundable: 'No', amount: '$ 75.00', comments: 'Standard license registration fee' },
                { type: 'Expideted', refundable: 'No', amount: '$ 125.00', comments: 'Fee for expedited processing service' }
            ],
            duration: {
                processing: '5-7 business days',
                term: '1 Year',
                renewable: 'Yes',
                requirements: 'Active brokerage sponsorship and annual licensing renewal compliance'
            },
            additionalInfo: 'Salespersons must operate strictly under the supervision of a licensed Real Estate Broker.'
        },
        '3': {
            processingTime: '10-12 weeks',
            overview: 'The Interim Teacher’s Certificate (Form C) is designed for internationally trained educators seeking to practice in New Brunswick.',
            linkUrl: 'https://www2.gnb.ca/content/gnb/en/departments/education/k12/content/teacher_certification.html',
            linkText: 'New Brunswick Education and Early Childhood Development, Teacher Certification Acts',
            whoTitle: 'Who should apply for an Interim Certificate?',
            whoSub: 'This pathway is for educators who:',
            whoList: [
                'Completed teacher preparation programs outside of Canada.',
                'Possess academic and professional credentials equivalent to NB standards.',
                'Demonstrate English or French language proficiency.'
            ],
            requirements: [
                'Successful completion of an approved teacher education program.',
                'Official transcripts sent directly from the issuing institution.',
                'Valid Statement of Professional Standing from original licensing jurisdiction.'
            ],
            howToApply: [
                'Download and complete the Form C application package.',
                'Gather all supporting documentation and verified translations.',
                'Submit the application fee via the approved payment portal.'
            ],
            fees: [
                { type: 'Interim Assessment Fee', refundable: 'No', amount: '$ 120.00', comments: 'Evaluation of international credentials' },
                { type: 'Certificate Issuance', refundable: 'No', amount: '$ 40.00', comments: 'Fee for first-time interim certificate' }
            ],
            duration: {
                processing: '10-12 weeks',
                term: 'Fixed-term (Up to 5 years)',
                renewable: 'Conditional Renewal',
                requirements: 'Completion of NB teaching practicum'
            },
            additionalInfo: 'Applicants must disclose any past disciplinary actions or criminal convictions.'
        }
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.title = currentPageReference.state?.title;
            this.description = currentPageReference.state?.description;
            this.licenseId = currentPageReference.state?.id;

            // Maps license details by ID or defaults to ID '3'
            this.selectedData = this.licenseDetailsMap[String(this.licenseId)] || this.licenseDetailsMap['3'];
        }
    }
}