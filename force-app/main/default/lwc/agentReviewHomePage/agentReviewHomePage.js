import { LightningElement, track } from 'lwc';

const STORAGE_KEY = 'arp_review_page';
const EVENT_NAME = 'arpreviewnavigate';
const APP_PAGES = new Set(['dashboard']);

export default class AgentReviewHomePage extends LightningElement {
    @track pageMode = 'dashboard';

    connectedCallback() {
        const stored = this.readPage();
        this.pageMode = stored === 'queue' ? 'dashboard' : (stored || 'dashboard');
        if (stored === 'queue') {
            this.writePage('dashboard');
        }
        this._onNav = (event) => {
            if (event?.detail?.page) {
                const next = event.detail.page === 'queue' ? 'dashboard' : event.detail.page;
                this.pageMode = next;
                this.writePage(next);
            }
        };
        window.addEventListener(EVENT_NAME, this._onNav);
    }

    disconnectedCallback() {
        window.removeEventListener(EVENT_NAME, this._onNav);
    }

    get isApplicationMode() {
        return APP_PAGES.has(this.pageMode);
    }

    get isOrgAdminMode() {
        return !this.isApplicationMode;
    }

    get applicationPageMode() {
        return 'dashboard';
    }

    handleOrgNavigate(event) {
        const page = event?.detail?.page;
        if (!page) {
            return;
        }
        this.pageMode = page;
        this.writePage(page);
        window.dispatchEvent(
            new CustomEvent(EVENT_NAME, {
                detail: { page },
                bubbles: true,
                composed: true
            })
        );
    }

    readPage() {
        try {
            return window.sessionStorage.getItem(STORAGE_KEY);
        } catch (e) {
            return null;
        }
    }

    writePage(page) {
        try {
            window.sessionStorage.setItem(STORAGE_KEY, page);
        } catch (e) {
            // ignore
        }
    }
}