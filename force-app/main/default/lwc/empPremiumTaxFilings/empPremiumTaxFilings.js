import { LightningElement, track, wire } from 'lwc';
import getFilingsByType from '@salesforce/apex/EMP_PremiumTaxCtrl.getFilingsByType';

const FORM_ROUTES = {
    PremiumTax: '/employerportal/s/premium-tax-application',
    FireMarshal: '/employerportal/s/fire-marshal-levy',
    VehicleLevy: '/employerportal/s/vehicle-levy'
};

const TILES = [
    {
        type: 'PremiumTax',
        title: 'Premium Tax',
        description:
            'Quarterly return: enter taxable premiums, system calculates levy, record payment to Province with remittance proof.',
        openLabel: 'Open Premium Tax form →',
        selectLabel: 'Select Premium Tax →',
        selectedLabel: 'Selected ✓',
        empty: 'No premium tax returns yet.',
        manageSuffix: "'s premium tax returns."
    },
    {
        type: 'FireMarshal',
        title: 'Fire Marshal Levy',
        description:
            'System expected amount from financial data. Report amount paid to Province and upload proof for FCNB approval.',
        openLabel: 'Open Fire Marshal form →',
        selectLabel: 'Select Fire Marshal →',
        selectedLabel: 'Selected ✓',
        empty: 'No Fire Marshal Levy filings yet.',
        manageSuffix: "'s Fire Marshal Levy filings."
    },
    {
        type: 'VehicleLevy',
        title: 'Vehicle Levy',
        description:
            'Staff-assessed amount. Record payment to Province; shortfall can true-up on the next quarterly invoice.',
        openLabel: 'Open Vehicle Levy form →',
        selectLabel: 'Select Vehicle Levy →',
        selectedLabel: 'Selected ✓',
        empty: 'No Vehicle Levy filings yet.',
        manageSuffix: "'s Vehicle Levy filings."
    }
];

/**
 * Employer Portal – Tax / Levy filings hub.
 * Top tiles open forms; bottom tiles filter the returns list.
 */
export default class EmpPremiumTaxFilings extends LightningElement {
    @track selectedType = 'PremiumTax';
    @track isLoading = true;
    @track errorMessage = '';
    @track accountName = '';
    @track returns = [];

    labels = {
        returns: 'Returns',
        loading: 'Loading filings',
        managePrefix: 'Manage ',
        filterHeading: 'View filings'
    };

    @wire(getFilingsByType, { filingType: '$selectedType' })
    wiredPage({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.accountName = data.accountName || '';
            this.returns = (data.returns || []).map((row) => ({
                ...row,
                statusClass: row.isPaid ? 'status-pill paid' : 'status-pill unpaid'
            }));
            this.errorMessage = '';
        } else if (error) {
            this.errorMessage =
                error?.body?.message || error.message || 'Unable to load filings.';
            this.returns = [];
        }
    }

    get openTiles() {
        return TILES.map((tile) => ({
            ...tile,
            className: 'pick',
            footerLabel: tile.openLabel
        }));
    }

    get filterTiles() {
        return TILES.map((tile) => {
            const selected = tile.type === this.selectedType;
            return {
                ...tile,
                className: selected ? 'pick pick-selected' : 'pick',
                footerLabel: selected ? tile.selectedLabel : tile.selectLabel,
                ariaPressed: selected ? 'true' : 'false'
            };
        });
    }

    get selectedTile() {
        return TILES.find((t) => t.type === this.selectedType) || TILES[0];
    }

    get sectionTitle() {
        return this.selectedTile.title;
    }

    get subtitle() {
        if (this.accountName) {
            return this.labels.managePrefix + this.accountName + this.selectedTile.manageSuffix;
        }
        return `Manage your ${this.selectedTile.title} filings.`;
    }

    get emptyLabel() {
        return this.selectedTile.empty;
    }

    get hasReturns() {
        return this.returns && this.returns.length > 0;
    }

    get showEmpty() {
        return !this.isLoading && !this.errorMessage && !this.hasReturns;
    }

    handleOpenForm(event) {
        const formType = event.currentTarget.dataset.type || 'PremiumTax';
        const route = FORM_ROUTES[formType] || FORM_ROUTES.PremiumTax;
        window.open(route, '_self');
    }

    handleSelectTile(event) {
        const type = event.currentTarget.dataset.type || 'PremiumTax';
        if (type === this.selectedType) {
            return;
        }
        this.isLoading = true;
        this.errorMessage = '';
        this.returns = [];
        this.selectedType = type;
    }
}