import { LightningElement, api, track } from 'lwc';
import authenticateUser from '@salesforce/apex/EmpLoginController.authenticateUser';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import setLanguage from '@salesforce/apex/EMP_LanguageCtrl.setLanguage';
import LPI_DESIGN from '@salesforce/resourceUrl/LPI_Design';
import {
    PUBLIC_PAGE_LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage,
    writeStoredLanguage
} from 'c/lpLanguageUtils';

const REMEMBER_KEY = 'lpi_portal_login_username';

export default class LpiPortalLogin extends LightningElement {
    _showRegister = false;

    @api
    get showRegister() {
        return this._showRegister;
    }
    set showRegister(value) {
        this._showRegister = value === true || value === 'true';
    }

    @track username = '';
    @track password = '';
    @track rememberMe = false;
    @track errorMessage = '';
    @track isSubmitting = false;
    @track selectedLanguage = 'en_US';
    @track labels = {
        loginTitle: 'Log in',
        loginSubtitle: 'Hello there, log in to the screen below',
        loginRequiredHint: 'Asterisk (*) indicates required field',
        loginUsername: 'Username',
        loginPassword: 'Password',
        loginRememberMe: 'Remember me',
        loginForgotUsername: 'Forgot Username?',
        loginForgotPassword: 'Forgot Password?',
        loginButton: 'Log in',
        loginLoggingIn: 'Logging in…',
        loginNoAccount: "Don't have an account?",
        loginRegisterLink: 'Register',
        loginCredentialsRequired: 'Username and Password are required.',
        loginUnable: 'Unable to log in. Please try again.',
        loginBrandAlt: 'Financial and Consumer Services of New Brunswick',
        language: 'Language',
        english: 'English',
        french: 'French'
    };

    logoUrl = LPI_DESIGN + '/media/images/ibm-logo-white.svg';
    bgUrl = LPI_DESIGN + '/media/images/login-bg.svg';

    get languageOptions() {
        return [
            { label: this.labels.english || 'English', value: 'en_US' },
            { label: this.labels.french || 'French', value: 'fr' }
        ];
    }

    connectedCallback() {
        const stored = readStoredLanguage();
        const urlLang = this.readUrlLanguage();
        // Prefer stored portal language over Experience Cloud ?language=en_US on the URL
        this.selectedLanguage = stored || urlLang || 'en_US';
        if (this.selectedLanguage === 'fr' || this.selectedLanguage === 'en_US') {
            writeStoredLanguage(this.selectedLanguage);
        }
        this.loadLabels();
        try {
            const saved = window.localStorage.getItem(REMEMBER_KEY);
            if (saved) {
                this.username = saved;
                this.rememberMe = true;
            }
        } catch (e) {
            // ignore storage errors
        }
    }

    readUrlLanguage() {
        try {
            const params = new URL(window.location.href).searchParams;
            const lang = params.get('language') || params.get('lang');
            if (lang && lang.startsWith('fr')) {
                return 'fr';
            }
            if (lang === 'en_US' || lang === 'en') {
                return 'en_US';
            }
        } catch (e) {
            // ignore
        }
        return null;
    }

    loadLabels() {
        const lang = this.selectedLanguage || readStoredLanguage() || 'en_US';
        const apiNames = PUBLIC_PAGE_LABEL_API_NAMES.filter((n) => n.startsWith('LP_Login_'));
        getLabels({ apiNames, language: lang })
            .then((apiMap) => {
                this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
            })
            .catch(() => {
                // keep English defaults
            });
    }

    handleLanguageChange(event) {
        const next = event.detail.value;
        if (!next || next === this.selectedLanguage) {
            return;
        }
        writeStoredLanguage(next);
        setLanguage({ languageLocaleKey: next }).catch(() => {
            // Guest users may be blocked from User language update
        });
        this.selectedLanguage = next;
        // Reload with language query so Experience Cloud and labels stay in sync
        try {
            const url = new URL(window.location.href);
            url.searchParams.set('language', next);
            window.location.href = url.toString();
        } catch (e) {
            window.location.reload();
        }
    }

    get loginBackgroundStyle() {
        return `background-image: url(${this.bgUrl}); background-color: #25428b; background-size: cover; background-position: center;`;
    }

    get submitLabel() {
        return this.isSubmitting
            ? this.labels.loginLoggingIn || 'Logging in…'
            : this.labels.loginButton || 'Log in';
    }

    get basePath() {
        const path = window.location.pathname || '';
        const idx = path.indexOf('/s/');
        if (idx >= 0) {
            return path.substring(0, idx);
        }
        return '';
    }

    get forgotPasswordUrl() {
        return `${this.basePath}/s/login/ForgotPassword`;
    }

    get forgotUsernameUrl() {
        return `${this.basePath}/s/forgot-username`;
    }

    get registerUrl() {
        const lang = this.selectedLanguage || readStoredLanguage() || 'en_US';
        return `${this.basePath}/s/registration?language=${encodeURIComponent(lang)}`;
    }

    handleUsernameChange(event) {
        this.username = event.target.value;
        this.errorMessage = '';
    }

    handlePasswordChange(event) {
        this.password = event.target.value;
        this.errorMessage = '';
    }

    handleRememberMe(event) {
        this.rememberMe = event.target.checked;
    }

    handleKeyDown(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            this.handleLogin();
        }
    }

    async handleLogin() {
        if (!this.username || !this.password) {
            this.errorMessage =
                this.labels.loginCredentialsRequired || 'Username and Password are required.';
            return;
        }
        this.isSubmitting = true;
        this.errorMessage = '';
        try {
            const result = await authenticateUser({
                username: this.username,
                password: this.password
            });
            if (!result || result.startsWith('Invalid') || result.startsWith('Error:')) {
                this.errorMessage = result || 'Invalid username or password';
                return;
            }
            try {
                if (this.rememberMe) {
                    window.localStorage.setItem(REMEMBER_KEY, this.username);
                } else {
                    window.localStorage.removeItem(REMEMBER_KEY);
                }
            } catch (e) {
                // ignore
            }
            window.location.href = result;
        } catch (error) {
            this.errorMessage =
                error?.body?.message ||
                error?.message ||
                this.labels.loginUnable ||
                'Unable to log in. Please try again.';
        } finally {
            this.isSubmitting = false;
        }
    }

    handleLogoClick(){
        window.location.href = '/s';
    }
}