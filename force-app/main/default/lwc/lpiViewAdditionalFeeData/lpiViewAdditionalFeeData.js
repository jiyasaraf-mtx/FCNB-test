import { LightningElement, api } from 'lwc';

export default class LpiViewAdditionalFeeData extends LightningElement {
    @api feeData;


    get getTotalAmount(){
        const totalPrice = this.feeData.reduce((accumulator ,item) => {
            return accumulator += item.feeAmount;
          }, 0)
        return totalPrice;
    }
}