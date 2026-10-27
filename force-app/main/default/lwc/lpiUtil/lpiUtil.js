import {
    LightningElement
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
export default class LpiUtil extends LightningElement {}

export function showAsyncErrorMessage(component, error) {
    showMessage(component, {
        title: "Error",
        message: (typeof error === 'string') ? error : ((error) ? ((error.message) ? error.message : ((error.body) ? ((error.body.message) ? error.body.message : JSON.stringify(error)) : JSON.stringify(error))) : "Something went wrong!"),
        messageType: 'error',
        mode: 'dismissible',
    });
}

export function showMessage(component, {
    title,
    message,
    messageType,
    mode
}) {
    component.dispatchEvent(new ShowToastEvent({
        mode,
        title,
        message,
        variant: messageType,
    }));
}

// linkable toas message for eg:  Click here "https://example.com/"

export function showMessageLinkable(component, {
    title,
    message,
    messageData,
    messageType,
    mode
}) {
    component.dispatchEvent(new ShowToastEvent({
        mode,
        title,
        message,
        messageData,
        variant: messageType,
    }));
}

export function formatPhoneNumber(value) {
    var numbers = value.replace(/\D/g, ""),
        char = {
            0: "(",
            3: ") ",
            6: "-"
        };
    value = "";
    for (var i = 0; i < numbers.length; i++) {
        value += (char[i] || "") + numbers[i];
    }
    return value;
}

export function checkLength(input) {
    if (!input.required || input.type == 'checkbox') {
        return true;
    }
    return (input && input.value && input.value.trim().length > 0);
}

/**
 * @lastModifiedBy Mohit Karani
 * @email mohit.karani@mtxb2b.com
 * @desc combines the address fiedls.
 */
export function getMergedAddress(address) {
    let addressApp;
    if (address.streetOne || address.city || address.stateLabel || address.zipCode) {
        addressApp = [address.streetOne, address.city, address.stateLabel, address.zipCode];
        addressApp = addressApp.filter(function (el) {
            return el != null && el !== "";
        });
        return addressApp;
    }
    return null;
}

export function addYears(date,years) {
    if(!date) return;
    date.setFullYear(date.getFullYear() + years);
    return date;
}