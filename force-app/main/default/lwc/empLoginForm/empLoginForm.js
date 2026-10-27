import { LightningElement, track } from 'lwc';
import authenticateUser from '@salesforce/apex/EmpLoginController.authenticateUser';
export default class EmpLoginForm extends LightningElement {
    @track username = '';
    @track password = '';
    @track errorMessage = '';
    handleUsernameChange(event) {
        this.username = event.target.value;
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
    }

    handleLogin() {
        authenticateUser({ username: this.username, password: this.password })
            .then(result => {
                if (result != '' || result !=null) {
                    // Redirect to community home page or another page
                    window.location.href = result;
                }
            })
            .catch(error => {
                this.errorMessage = 'An error occurred: ' + error.body.message;
                console.log('OUTPUT : ',this.errorMessage);
                console.log('error : ',JSON.stringify(this.errorMessage));
            });
    }
}