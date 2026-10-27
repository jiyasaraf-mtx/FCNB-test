import { LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";


export default class CleanSessionStorage extends OmniscriptBaseMixin(LightningElement) {
	connectedCallback() {
		if (sessionStorage.getItem('userProfile')) {
			sessionStorage.removeItem('userProfile')
		}
	}

}