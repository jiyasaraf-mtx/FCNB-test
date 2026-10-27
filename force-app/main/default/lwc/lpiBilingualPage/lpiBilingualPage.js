import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import WelcomeToShow from '@salesforce/label/c.Label_for_Welcome';

export default class LpiBilingualPage extends LightningElement {
    welcomeMessage = WelcomeToShow;
}