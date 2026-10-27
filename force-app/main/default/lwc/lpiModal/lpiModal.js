import { LightningElement, api } from 'lwc';

export default class LpiModal extends LightningElement {
    @api isLarge = false;
    @api isSmall = false;
    @api title = 'Popup';
    @api isHeaderless = false;

    get getModalStyle(){
        return `slds-modal slds-fade-in-open slds-modal_${this.isLarge ? 'large' : this.isSmall ? 'x-small': 'medium'}`;
    }
    connectedCallback(){
        setTimeout(() => {
            this.focusFirstEle(this,null);
        }, 200);
    }
    @api
    set getMyFocus(value) {
        if(value) {
           setTimeout(() => {
                this.focusFirstEle(this,null);
            }, 200);
        }
    }

    get getMyFocus() {
        return;
    }
    @api
    set getFocusOnFirst(value) {
        if(value) {
            console.log('SETTING FOCUS HERE >> ');
            this.focusFirstEle(this,null);
        }
    }
    get getFocusOnFirst() {
        return;
    }

    handleModalClose(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleEscKeyDown(event) {
        if (event.code === 'Escape' || event.keyCode === 27) {
            this.handleModalClose();
        } else if(event.target === this.template.activeElement && (event.code ==='Tab' || event.keyCode === 9)) {
            this.dispatchEvent(new CustomEvent('tabpress'));
        }
    }
    
    @api
     // Focus Leak Acessibiltiy Issue 
     focusFirstEle(component,element) {
        const focusableElements = 'lightning-combobox, lightning-button-icon, button, lightning-helptext, lightning-input, lightning-button, lightning-radio-group, lightning-icon';
        const modal = component.template.querySelector('.slds-modal');
        
        const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
        const focusableContent = modal.querySelectorAll(focusableElements);
        const lastFocusableElement = focusableContent[focusableContent.length - 1];
        if(element) {
            const focusableElement = modal.querySelectorAll(focusableElements)[element];
            focusableElement.focus();
        }
        else {
            firstFocusableElement.focus();
        }
        component.template.addEventListener('keydown', function(event) {
            let isTabPressed = event.key === 'Tab' || event.keyCode === 9;
            if (!isTabPressed) {
                return;
            }
            if (event.shiftKey) {       
                if (component.template.activeElement === firstFocusableElement) {
                    lastFocusableElement.focus(); 
                    event.stopPropagation()
                    event.preventDefault();
                }
            } else { 
                if (component.template.activeElement === lastFocusableElement) {  
                    firstFocusableElement.focus(); 
                    event.preventDefault();
                    event.stopPropagation()
                }
            }
        });
    }
}