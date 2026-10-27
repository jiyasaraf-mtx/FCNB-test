import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import {
    buildOmniLwcName,
    resolveOmniLanguageCode,
    readStoredLanguage
} from 'c/lpLanguageUtils';

const OS_TYPE = 'FCNB';
const OS_SUBTYPE = 'AVRFiling';
const OS_LANGUAGE = 'Multi-Language';

/**
 * Host for Pension Portal AVR Filing OmniScript.
 * Prefer dropping the OmniScript component (Type/SubType/Language) on the page.
 * This host can also launch via omnistudio__vlocityLWCOmniWrapper using c__target.
 */
export default class AvrFilingOmniHost extends NavigationMixin(LightningElement) {
    @api recordId;

    @track labels = {
        avrFiling: 'AVR Filing',
        omniHostHelp:
            'Add the OmniScript component to this page (Type FCNB / SubType AVRFiling / Multi-Language), or use Launch to open the compiled OmniScript wrapper.',
        launchOmni: 'Launch AVR Filing'
    };

    contextId;
    language = 'en_US';
    showFallback = true;

    @wire(CurrentPageReference)
    wiredPageRef(pageRef) {
        if (!pageRef) {
            return;
        }
        const state = pageRef.state || {};
        this.contextId = state.c__ContextId || state.ContextId || this.recordId || null;
        this.language =
            state.c__language || readStoredLanguage() || resolveOmniLanguageCode() || 'en_US';

        // If page already has c__target for our OS, hide fallback UI
        const target = (state.c__target || '').toLowerCase();
        const expected = ('c:' + buildOmniLwcName(OS_TYPE, OS_SUBTYPE, OS_LANGUAGE)).toLowerCase();
        if (target && target === expected) {
            this.showFallback = false;
            this.handleLaunch();
        }
    }

    get displayContextId() {
        return this.contextId || '— (new filing)';
    }

    get omniTarget() {
        return 'c:' + buildOmniLwcName(OS_TYPE, OS_SUBTYPE, OS_LANGUAGE);
    }

    handleLaunch() {
        const state = {
            c__target: this.omniTarget,
            c__layout: 'lightning',
            c__tabIcon: 'custom:custom18',
            c__tabLabel: 'AVR Filing',
            c__language: this.language || resolveOmniLanguageCode()
        };
        if (this.contextId) {
            state.c__ContextId = this.contextId;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'omnistudio__vlocityLWCOmniWrapper'
            },
            state
        });
    }
}