import { LightningElement, api, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import transactionsCss from "@salesforce/resourceUrl/LPI_ApplicationTransactions";

const APP_ID = "IA-0000000550";
const APPLICANT = "Amira Patel";
const CURRENT_USER = "Jason Smith";

const FEE_CATALOG = [
	{
		name: "Life Insurance Agent Application Fee",
		code: "FEE-INS-AGENT-NEW",
		amount: 125,
		category: "Application Fee",
		gl: "4100-INS-LIC",
		division: "Insurance",
		description:
			"Base fee for Individual Life Insurance Agent (includes A&S) application."
	},
	{
		name: "Administrative Fine",
		code: "FEE-FINE-ADMIN",
		amount: 500,
		category: "Fine",
		gl: "4300-FINE",
		division: "Enforcement",
		description: "Administrative fine assessed under FCNB regulatory authority."
	},
	{
		name: "Late Filing Fine",
		code: "FEE-FINE-LATE",
		amount: 250,
		category: "Fine",
		gl: "4300-FINE",
		division: "All",
		description: "Fine for late filing or non-compliance with filing deadline."
	},
	{
		name: "Real Estate Salesperson Application Fee",
		code: "FEE-RE-SP-NEW",
		amount: 75,
		category: "Application Fee",
		gl: "4100-RE-LIC",
		division: "Consumer Affairs",
		description: "Base salesperson licence application fee."
	},
	{
		name: "Expedited Service Fee",
		code: "FEE-RE-EXP-2DAY",
		amount: 150,
		category: "Service Fee",
		gl: "4200-RE-EXP",
		division: "Consumer Affairs",
		description: "Optional 2-day expedited processing fee."
	},
	{
		name: "Agent Branch Fee",
		code: "FEE-RE-BRANCH",
		amount: 100,
		category: "Application Fee",
		gl: "4100-RE-BR",
		division: "Consumer Affairs",
		description: "Per-branch fee used in licence fee recalculation."
	},
	{
		name: "Late Renewal Fee",
		code: "FEE-LATE-RENEW",
		amount: 50,
		category: "Late Fee",
		gl: "4300-LATE",
		division: "All",
		description: "Automatic late fee when renewal is past due."
	},
	{
		name: "NSF Fee",
		code: "FEE-NSF",
		amount: 45,
		category: "NSF Fee",
		gl: "4300-NSF",
		division: "All",
		description: "Fee assessed when a payment is returned NSF."
	}
];

const PAY_METHODS = [
	{ label: "Cheque", value: "Cheque" },
	{ label: "Money Order", value: "Money Order" },
	{ label: "EFT", value: "EFT" },
	{ label: "Credit Card", value: "Credit Card" },
	{ label: "Interac", value: "Interac" },
	{ label: "Cash", value: "Cash" }
];

const REFUND_METHODS = [
	{ label: "Cheque", value: "Cheque" },
	{ label: "EFT", value: "EFT" }
];

const REFUND_REASONS = [
	{ label: "Overpayment", value: "Overpayment" },
	{ label: "Duplicate payment", value: "Duplicate payment" },
	{ label: "Fee waived", value: "Fee waived" },
	{ label: "Application withdrawn", value: "Application withdrawn" },
	{ label: "Billing error", value: "Billing error" },
	{ label: "Other", value: "Other" }
];

const VOID_REASONS = [
	{ label: "Entered in error", value: "Entered in error" },
	{ label: "NSF (Non-Sufficient Funds)", value: "NSF" },
	{ label: "Duplicate payment", value: "Duplicate payment" },
	{ label: "Other", value: "Other" }
];

function money(n) {
	return `$${Number(n || 0).toFixed(2)}`;
}

function nowStamp() {
	return new Date().toLocaleString([], {
		month: "short",
		day: "numeric",
		year: "numeric",
		hour: "2-digit",
		minute: "2-digit"
	});
}

function todayISO() {
	return new Date().toISOString().slice(0, 10);
}

function badgeClass(status) {
	const s = String(status).toLowerCase();
	if (
		["paid", "posted", "processed", "assessed", "available", "queued"].includes(
			s
		)
	) {
		return "lpi-tx-badge_success";
	}
	if (
		[
			"open",
			"partial",
			"pending",
			"pending refund",
			"pending approval"
		].includes(s)
	) {
		return "lpi-tx-badge_warning";
	}
	if (["refunded", "voided", "nsf", "reversed"].includes(s)) {
		return "lpi-tx-badge_error";
	}
	return "";
}

function fieldsToList(fields) {
	if (!fields) {
		return [];
	}
	return Object.entries(fields).map(([label, value]) => ({
		label,
		value: String(value)
	}));
}

function refLabelForMethod(method) {
	return (
		{
			Cheque: "Cheque Number",
			EFT: "EFT Reference",
			"Credit Card": "Gateway Confirmation ID",
			Interac: "Interac Reference",
			Cash: "Receipt Number",
			"Money Order": "Money Order Number"
		}[method] || "Reference"
	);
}

function dateLabelForMethod(method) {
	return (
		{
			Cheque: "Cheque Date",
			EFT: "Transfer Date",
			"Credit Card": "Payment Date",
			Interac: "Payment Date",
			Cash: "Received Date",
			"Money Order": "Money Order Date"
		}[method] || "Date"
	);
}

export default class LpiApplicationTransactions extends LightningElement {
	@api recordId;

	@track records = [];
	@track auditLog = [];
	@track selectedId = null;
	@track toastMessage = "";
	@track toastVisible = false;
	@track activeTab = "transaction";

	@track showFeeModal = false;
	@track showPayModal = false;
	@track showGatewayModal = false;
	@track showRefundModal = false;
	@track showVoidModal = false;
	@track showInvoiceModal = false;

	@track feeSearch = "";
	@track feeLookupOpen = false;
	@track feeLookupMatches = [];
	@track selectedFee = null;
	@track autoInvoice = true;
	@track feeComment = "";

	@track payAmount = "";
	@track payMethod = "Cheque";
	@track payRef = "";
	@track payDate = "";
	@track payComment = "";
	@track payModeHint = "Enter an amount — the system detects exact, under, or over payment.";
	@track payModeClass = "lpi-tx-hint";
	@track gwAmountDisplay = "$0.00";
	@track gwStatus = "Click Pay securely to complete payment with the provider.";
	@track gwPayDisabled = false;

	@track refundAmount = "";
	@track refundMethod = "Cheque";
	@track refundReason = "Overpayment";
	@track refundOtherReason = "";
	@track refundComment = "";

	@track voidPaymentId = "";
	@track voidReason = "Entered in error";
	@track voidOtherReason = "";
	@track voidDate = "";
	@track voidBankReason = "Cheque returned — NSF";
	@track voidNsfFee = "45.00";
	@track voidComment = "";
	@track voidSummary = "";
	@track voidSummaryClass = "lpi-tx-hint";
	@track voidPaymentOptions = [];

	@track invoiceModalTitle = "Invoice Document";
	@track invoiceDoc = null;

	applied = 0;
	credit = 0;
	seq = 1;
	stylesLoaded = false;
	_toastTimer;

	payMethodOptions = PAY_METHODS;
	refundMethodOptions = REFUND_METHODS;
	refundReasonOptions = REFUND_REASONS;
	voidReasonOptions = VOID_REASONS;

	get payMethodSelectOptions() {
		return PAY_METHODS.map((o) => ({
			...o,
			selected: o.value === this.payMethod
		}));
	}

	get refundMethodSelectOptions() {
		return REFUND_METHODS.map((o) => ({
			...o,
			selected: o.value === this.refundMethod
		}));
	}

	get refundReasonSelectOptions() {
		return REFUND_REASONS.map((o) => ({
			...o,
			selected: o.value === this.refundReason
		}));
	}

	get voidReasonSelectOptions() {
		return VOID_REASONS.map((o) => ({
			...o,
			selected: o.value === this.voidReason
		}));
	}

	get voidPaymentSelectOptions() {
		return this.voidPaymentOptions.map((o) => ({
			...o,
			selected: o.value === this.voidPaymentId
		}));
	}

	connectedCallback() {
		loadStyle(this, transactionsCss).catch(() => {
			/* non-blocking */
		});
		this.stylesLoaded = true;
	}

	disconnectedCallback() {
		if (this._toastTimer) {
			clearTimeout(this._toastTimer);
		}
	}

	get appId() {
		return APP_ID;
	}

	get totalFees() {
		return this.records
			.filter((r) => r.type === "Fee")
			.reduce((s, r) => s + r.amount, 0);
	}

	get balanceDue() {
		return Math.max(Number((this.totalFees - this.applied).toFixed(2)), 0);
	}

	get kpiFees() {
		return money(this.totalFees);
	}

	get kpiDue() {
		return money(this.balanceDue);
	}

	get kpiCredit() {
		return money(this.credit);
	}

	get appStatus() {
		const fees = this.totalFees;
		const due = this.balanceDue;
		if (!fees) return "Draft";
		if (due === 0 && this.credit > 0) return "Paid — Credit Available";
		if (due === 0) return "Paid";
		if (this.applied > 0) return "Partially Paid";
		return "Fees Due";
	}

	get listCountLabel() {
		const n = this.records.length;
		return `${n} item${n === 1 ? "" : "s"}`;
	}

	get auditCountLabel() {
		const n = this.auditLog.length;
		return `${n} item${n === 1 ? "" : "s"}`;
	}

	get hasRecords() {
		return this.records.length > 0;
	}

	get hasAudit() {
		return this.auditLog.length > 0;
	}

	get payDisabled() {
		return this.totalFees === 0;
	}

	get voidDisabled() {
		return this.voidablePayments().length === 0;
	}

	get refundDisabled() {
		return this.credit <= 0;
	}

	get saveFeeDisabled() {
		return !this.selectedFee;
	}

	get feeLookupClass() {
		return `lpi-tx-lookup${this.feeLookupOpen ? " open" : ""}`;
	}

	get hasFeeLookupMatches() {
		return this.feeLookupMatches.length > 0;
	}

	get toastClass() {
		return `lpi-tx-toast${this.toastVisible ? " show" : ""}`;
	}

	get isTransactionTab() {
		return this.activeTab === "transaction";
	}

	get isRelatedTab() {
		return this.activeTab === "related";
	}

	get transactionTabClass() {
		return `slds-tabs_default__item${this.isTransactionTab ? " slds-is-active" : ""}`;
	}

	get relatedTabClass() {
		return `slds-tabs_default__item${this.isRelatedTab ? " slds-is-active" : ""}`;
	}

	get isCreditCard() {
		return this.payMethod === "Credit Card";
	}

	get showPayPostButton() {
		return !this.isCreditCard;
	}

	get payRefLabel() {
		return refLabelForMethod(this.payMethod);
	}

	get payDateLabel() {
		return dateLabelForMethod(this.payMethod);
	}

	get payBalanceHint() {
		return `Balance Due: ${money(this.balanceDue)}`;
	}

	get showRefundOther() {
		return this.refundReason === "Other";
	}

	get showVoidOther() {
		return this.voidReason === "Other";
	}

	get showVoidNsf() {
		return this.voidReason === "NSF";
	}

	get selectedRecord() {
		return this.records.find((r) => r.id === this.selectedId) || null;
	}

	get hasSelectedRecord() {
		return !!this.selectedRecord;
	}

	get selectedDisplayName() {
		const r = this.selectedRecord;
		if (!r) return "";
		return r.type === "Invoice" ? r.docName : r.name;
	}

	get selectedSubline() {
		const r = this.selectedRecord;
		if (!r) return "";
		return `${r.id} · ${r.created}`;
	}

	get selectedBadgeClass() {
		const r = this.selectedRecord;
		return r ? `lpi-tx-badge ${badgeClass(r.status)}` : "lpi-tx-badge";
	}

	get selectedBadgeLabel() {
		const r = this.selectedRecord;
		return r ? `${r.type} · ${r.status}` : "";
	}

	get selectedAmount() {
		return this.selectedRecord ? money(this.selectedRecord.amount) : "";
	}

	get selectedFieldList() {
		return this.selectedRecord
			? fieldsToList(this.selectedRecord.fields)
			: [];
	}

	get selectedNotes() {
		return this.selectedRecord?.notes || "";
	}

	get showOpenInvoiceAction() {
		return this.selectedRecord?.type === "Invoice";
	}

	get showVoidFromDetailAction() {
		const r = this.selectedRecord;
		return r?.type === "Payment" && r.status === "Posted";
	}

	get showApproveNsfAction() {
		const r = this.selectedRecord;
		return r?.type === "NSF Alert" && r.status === "Pending Approval";
	}

	get showRefundFromDetailAction() {
		const r = this.selectedRecord;
		return r?.type === "Credit" && r.status === "Available";
	}

	get showApproveRefundAction() {
		const r = this.selectedRecord;
		return r?.type === "Refund" && r.status === "Pending";
	}

	get displayRecords() {
		return this.records.map((r) => ({
			...r,
			amountDisplay: money(r.amount),
			badgeClass: `lpi-tx-badge ${badgeClass(r.status)}`,
			rowClass: r.id === this.selectedId ? "selected" : "",
			isInvoice: r.type === "Invoice",
			displayName: r.type === "Invoice" ? r.docName : r.name
		}));
	}

	nextId(prefix) {
		return `${prefix}-${String(this.seq++).padStart(4, "0")}`;
	}

	voidablePayments() {
		return this.records.filter(
			(r) => r.type === "Payment" && r.status === "Posted"
		);
	}

	toast(msg) {
		this.toastMessage = msg;
		this.toastVisible = true;
		if (this._toastTimer) {
			clearTimeout(this._toastTimer);
		}
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		this._toastTimer = setTimeout(() => {
			this.toastVisible = false;
		}, 2600);
	}

	logAudit(action, recordLabel, detail, user) {
		this.auditLog = [
			{
				id: `AUD-${Date.now()}-${this.auditLog.length}`,
				date: nowStamp(),
				action,
				record: recordLabel,
				detail,
				user: user || CURRENT_USER
			},
			...this.auditLog
		];
	}

	syncInvoiceStatuses() {
		let remaining = this.applied;
		const invoices = [...this.records]
			.filter((r) => r.type === "Invoice")
			.reverse();
		invoices.forEach((inv) => {
			if (remaining >= inv.amount) {
				inv.status = "Paid";
				remaining = Number((remaining - inv.amount).toFixed(2));
			} else if (remaining > 0) {
				inv.status = "Partial";
				remaining = 0;
			} else {
				inv.status = "Open";
			}
		});
		this.records = [...this.records];
	}

	addRecord(rec, silent) {
		this.records = [rec, ...this.records];
		this.selectedId = rec.id;
		this.logAudit(
			"Created",
			rec.type,
			`${rec.name} · ${money(rec.amount)} · ${rec.status}`
		);
		if (!silent) {
			this.toast(`${rec.type} "${rec.name}" created`);
		}
		this.syncInvoiceStatuses();
	}

	/* Tabs */
	handleTabClick(event) {
		event.preventDefault();
		this.activeTab = event.currentTarget.dataset.tab;
	}

	/* Selection */
	handleRowClick(event) {
		const id = event.currentTarget.dataset.id;
		if (!id) return;
		this.selectedId = id;
	}

	handleInvoiceLinkClick(event) {
		event.preventDefault();
		event.stopPropagation();
		const id = event.currentTarget.dataset.id;
		this.selectedId = id;
		this.openInvoiceDoc(id);
	}

	/* Fee modal */
	openFeeModal() {
		this.clearFeeForm();
		this.showFeeModal = true;
	}

	closeFeeModal() {
		this.showFeeModal = false;
		this.feeLookupOpen = false;
	}

	clearFeeForm() {
		this.selectedFee = null;
		this.feeSearch = "";
		this.feeComment = "";
		this.autoInvoice = true;
		this.feeLookupOpen = false;
		this.feeLookupMatches = [];
	}

	get feeCode() {
		return this.selectedFee?.code || "";
	}

	get feeAmountDisplay() {
		return this.selectedFee ? money(this.selectedFee.amount) : "";
	}

	get feeCategory() {
		return this.selectedFee?.category || "";
	}

	get feeGL() {
		return this.selectedFee?.gl || "";
	}

	get feeDesc() {
		return this.selectedFee?.description || "";
	}

	openLookup(query) {
		const q = (query || "").trim().toLowerCase();
		const matches = FEE_CATALOG.filter(
			(f) =>
				!q ||
				f.name.toLowerCase().includes(q) ||
				f.code.toLowerCase().includes(q) ||
				f.category.toLowerCase().includes(q)
		).map((f) => ({
			key: f.code,
			idx: FEE_CATALOG.indexOf(f),
			name: f.name,
			meta: `${f.category} · ${f.code} · ${money(f.amount)}`
		}));
		this.feeLookupMatches = matches;
		this.feeLookupOpen = true;
	}

	handleFeeSearchFocus() {
		this.openLookup(this.feeSearch);
	}

	handleFeeSearchInput(event) {
		this.feeSearch = event.target.value;
		this.selectedFee = null;
		this.openLookup(this.feeSearch);
	}

	handleFeeLookupSelect(event) {
		const idx = Number(event.currentTarget.dataset.idx);
		const fee = FEE_CATALOG[idx];
		if (!fee) return;
		this.selectedFee = fee;
		this.feeSearch = fee.name;
		this.feeLookupOpen = false;
	}

	handleFeeCommentChange(event) {
		this.feeComment = event.target.value;
	}

	handleAutoInvoiceChange(event) {
		this.autoInvoice = event.target.checked;
	}

	saveFee() {
		if (!this.selectedFee) return;
		const feeId = this.nextId("FL");
		const feeComment = (this.feeComment || "").trim();
		const feeFields = {
			"Fee Code": this.selectedFee.code,
			Category: this.selectedFee.category,
			"GL Account": this.selectedFee.gl,
			Division: this.selectedFee.division,
			"Application ID": APP_ID
		};
		if (feeComment) feeFields.Comment = feeComment;

		this.addRecord(
			{
				id: feeId,
				type: "Fee",
				name: this.selectedFee.name,
				amount: this.selectedFee.amount,
				status: "Assessed",
				created: nowStamp(),
				fields: feeFields,
				notes: feeComment || this.selectedFee.description
			},
			true
		);

		if (this.autoInvoice) {
			const invId = this.nextId("INV");
			const issued = todayISO();
			const due = new Date(Date.now() + 14 * 86400000)
				.toISOString()
				.slice(0, 10);
			const docName = `Invoice_${invId}.pdf`;
			this.addRecord({
				id: invId,
				type: "Invoice",
				name: invId,
				docName,
				amount: this.selectedFee.amount,
				status: "Open",
				created: nowStamp(),
				fields: {
					"Fee Name": this.selectedFee.name,
					"Fee Code": this.selectedFee.code,
					Category: this.selectedFee.category,
					Division: this.selectedFee.division,
					"GL Account": this.selectedFee.gl,
					"Issued Date": issued,
					"Due Date": due,
					"Bill To": APPLICANT,
					"Application ID": APP_ID,
					"Document Type": "PDF"
				},
				notes: "Invoice document generated automatically when fee was saved.",
				relatedFeeId: feeId
			});
		} else {
			this.toast(`Fee "${this.selectedFee.name}" created`);
			this.syncInvoiceStatuses();
		}

		this.clearFeeForm();
		this.closeFeeModal();
	}

	/* Payment */
	openPayModal() {
		const due = this.balanceDue;
		this.payAmount = due > 0 ? due.toFixed(2) : "";
		this.payMethod = "Cheque";
		this.payRef = "";
		this.payDate = todayISO();
		this.payComment = "";
		this.updatePayHint();
		this.showPayModal = true;
	}

	closePayModal() {
		this.showPayModal = false;
	}

	handlePayAmountChange(event) {
		this.payAmount = event.target.value;
		this.updatePayHint();
	}

	handlePayMethodChange(event) {
		this.payMethod = event.target.value;
		this.payRef = "";
		this.payDate = todayISO();
	}

	handlePayRefChange(event) {
		this.payRef = event.target.value;
	}

	handlePayDateChange(event) {
		this.payDate = event.target.value;
	}

	handlePayCommentChange(event) {
		this.payComment = event.target.value;
	}

	updatePayHint() {
		const due = this.balanceDue;
		const amount = Number(this.payAmount);
		if (!(amount > 0)) {
			this.payModeHint = "Enter exact, under, or over amount.";
			this.payModeClass = "lpi-tx-hint";
			return;
		}
		const diff = Number((amount - due).toFixed(2));
		if (due === 0) {
			this.payModeHint = "Balance is $0.00 — amount posts as credit.";
			this.payModeClass = "lpi-tx-hint over";
		} else if (Math.abs(diff) < 0.005) {
			this.payModeHint = `Exact payment — settles ${money(due)}.`;
			this.payModeClass = "lpi-tx-hint exact";
		} else if (diff < 0) {
			this.payModeHint = `Underpayment — ${money(due - amount)} remains due.`;
			this.payModeClass = "lpi-tx-hint under";
		} else {
			this.payModeHint = `Overpayment — ${money(diff)} becomes credit.`;
			this.payModeClass = "lpi-tx-hint over";
		}
	}

	openPaymentProvider() {
		const amount = Number(this.payAmount);
		if (!(amount > 0)) {
			this.toast("Enter a valid amount first");
			return;
		}
		this.gwAmountDisplay = money(amount);
		this.gwStatus =
			"Click Pay securely to complete payment with the provider.";
		this.gwPayDisabled = false;
		this.showGatewayModal = true;
	}

	closeGatewayModal() {
		this.showGatewayModal = false;
	}

	completeGatewayPayment() {
		const amount = Number(this.payAmount);
		if (!(amount > 0)) {
			this.toast("Enter a valid amount");
			return;
		}
		const confId = "GW-" + Date.now().toString().slice(-8);
		this.gwStatus = `Payment approved. Confirmation ${confId}. Returning to Salesforce…`;
		this.gwPayDisabled = true;

		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(() => {
			this.closeGatewayModal();
			this.postPaymentRecord({
				amount,
				method: "Credit Card",
				ref: confId,
				date: todayISO(),
				comment: (this.payComment || "").trim(),
				extraFields: {
					"Gateway Confirmation ID": confId,
					"Payment Date": todayISO(),
					"Payment Channel": "External payment provider"
				}
			});
			this.closePayModal();
		}, 700);
	}

	postPaymentRecord({ amount, method, ref, date, comment, extraFields }) {
		const openBal = this.balanceDue;
		const appliedAmt = Math.min(amount, openBal);
		const unapplied = Number((amount - appliedAmt).toFixed(2));
		const payId = this.nextId("PAY");

		this.applied = Number((this.applied + appliedAmt).toFixed(2));
		if (unapplied > 0) {
			this.credit = Number((this.credit + unapplied).toFixed(2));
		}

		let notes = comment || "Payment posted.";
		if (unapplied > 0) {
			notes = `Overpayment: ${money(appliedAmt)} applied, ${money(unapplied)} credit.${comment ? ` ${comment}` : ""}`;
		} else if (Number((this.totalFees - this.applied).toFixed(2)) > 0) {
			notes = `Underpayment: ${money(appliedAmt)} applied, ${money(this.balanceDue)} still due.${comment ? ` ${comment}` : ""}`;
		} else {
			notes =
				(comment ? comment + " · " : "") +
				"Exact payment — balance cleared.";
		}

		const fields = {
			"Payment Method": method,
			[refLabelForMethod(method)]: ref,
			[dateLabelForMethod(method)]: date,
			Applied: money(appliedAmt),
			Unapplied: money(unapplied),
			"Application ID": APP_ID,
			...(extraFields || {})
		};
		if (comment) fields.Comment = comment;

		this.addRecord(
			{
				id: payId,
				type: "Payment",
				name: ref,
				amount,
				status: "Posted",
				created: nowStamp(),
				appliedAmt,
				unapplied,
				fields,
				notes
			},
			true
		);

		if (unapplied > 0) {
			this.addRecord({
				id: this.nextId("CR"),
				type: "Credit",
				name: `Credit from ${payId}`,
				amount: unapplied,
				status: "Available",
				created: nowStamp(),
				fields: { "Source Payment": payId, "Application ID": APP_ID },
				notes: "Unapplied overpayment available for refund.",
				sourcePayId: payId
			});
		} else {
			this.toast(`Payment ${ref} posted`);
			this.syncInvoiceStatuses();
		}
	}

	savePay() {
		const amount = Number(this.payAmount);
		const method = this.payMethod;
		if (method === "Credit Card") {
			this.openPaymentProvider();
			return;
		}
		const ref = (this.payRef || "").trim();
		const date = this.payDate || todayISO();
		const comment = (this.payComment || "").trim();

		if (!(amount > 0)) {
			this.toast("Enter a valid amount");
			return;
		}
		if (!ref) {
			this.toast(`Enter ${refLabelForMethod(method)}`);
			return;
		}
		if (!date) {
			this.toast(`Enter ${dateLabelForMethod(method)}`);
			return;
		}

		this.postPaymentRecord({ amount, method, ref, date, comment });
		this.closePayModal();
	}

	/* Void */
	handleOpenVoidFromToolbar() {
		this.openVoidModal();
	}

	openVoidModal(preselectId) {
		const pays = this.voidablePayments();
		if (!pays.length) {
			this.toast("No posted payments to void");
			return;
		}
		const preId =
			typeof preselectId === "string" ? preselectId : undefined;
		this.voidPaymentOptions = pays.map((p) => ({
			label: `${p.id} · ${p.name} · ${money(p.amount)} · ${p.fields["Payment Method"] || ""}`,
			value: p.id
		}));
		this.voidPaymentId =
			preId && pays.some((p) => p.id === preId) ? preId : pays[0].id;
		this.voidReason = "Entered in error";
		this.voidOtherReason = "";
		this.voidDate = todayISO();
		this.voidBankReason = "Cheque returned — NSF";
		this.voidNsfFee = "45.00";
		this.voidComment = "";
		this.updateVoidSummary();
		this.showVoidModal = true;
	}

	closeVoidModal() {
		this.showVoidModal = false;
	}

	handleVoidPaymentChange(event) {
		this.voidPaymentId = event.target.value;
		this.updateVoidSummary();
	}

	handleVoidReasonChange(event) {
		this.voidReason = event.target.value;
		if (this.voidReason !== "Other") this.voidOtherReason = "";
		this.updateVoidSummary();
	}

	handleVoidOtherReasonChange(event) {
		this.voidOtherReason = event.target.value;
	}

	handleVoidDateChange(event) {
		this.voidDate = event.target.value;
	}

	handleVoidBankReasonChange(event) {
		this.voidBankReason = event.target.value;
	}

	handleVoidNsfFeeChange(event) {
		this.voidNsfFee = event.target.value;
		this.updateVoidSummary();
	}

	handleVoidCommentChange(event) {
		this.voidComment = event.target.value;
	}

	updateVoidSummary() {
		const pay = this.records.find((r) => r.id === this.voidPaymentId);
		if (!pay) {
			this.voidSummary = "";
			return;
		}
		const appliedAmt = Number(pay.appliedAmt || 0);
		const unapplied = Number(pay.unapplied || 0);
		if (this.voidReason === "NSF") {
			const fee = Number(this.voidNsfFee) || 0;
			this.voidSummary =
				`Will reverse ${money(appliedAmt)} applied` +
				(unapplied > 0 ? ` and clear ${money(unapplied)} credit` : "") +
				`. NSF fee ${money(fee)} pending approval.`;
			this.voidSummaryClass = "lpi-tx-hint under";
		} else {
			this.voidSummary =
				`Will void this payment and restore ${money(appliedAmt)} to balance due` +
				(unapplied > 0
					? ` (also clears ${money(unapplied)} credit)`
					: "") +
				".";
			this.voidSummaryClass = "lpi-tx-hint";
		}
	}

	saveVoid() {
		const pay = this.records.find(
			(r) => r.id === this.voidPaymentId && r.type === "Payment"
		);
		if (!pay || pay.status !== "Posted") {
			this.toast("Select a posted payment");
			return;
		}

		let reason = this.voidReason;
		if (reason === "Other") {
			reason = (this.voidOtherReason || "").trim();
			if (!reason) {
				this.toast("Enter Other Reason");
				return;
			}
		}
		const isNsf = this.voidReason === "NSF";
		const voidDate = this.voidDate;
		const voidComment = (this.voidComment || "").trim();
		const appliedAmt = Number(pay.appliedAmt || 0);
		const unapplied = Number(pay.unapplied || 0);

		this.applied = Math.max(
			0,
			Number((this.applied - appliedAmt).toFixed(2))
		);
		if (unapplied > 0) {
			this.credit = Math.max(
				0,
				Number((this.credit - unapplied).toFixed(2))
			);
			this.records = this.records.map((r) => {
				if (
					r.type === "Credit" &&
					(r.sourcePayId === pay.id ||
						(r.fields && r.fields["Source Payment"] === pay.id))
				) {
					if (
						r.status === "Available" ||
						r.status === "Pending Refund"
					) {
						return { ...r, status: "Cleared" };
					}
				}
				return r;
			});
		}

		const updatedPay = {
			...pay,
			status: isNsf ? "NSF" : "Voided",
			fields: {
				...pay.fields,
				"Void Reason": isNsf ? "NSF" : reason,
				"Void Date": voidDate,
				"Voided By": CURRENT_USER,
				Applied: money(0),
				Unapplied: money(0)
			},
			notes: isNsf
				? `Payment returned NSF. Applied amount ${money(appliedAmt)} reversed.`
				: `Payment voided (${reason}). Applied amount ${money(appliedAmt)} reversed.`,
			appliedAmt: 0,
			unapplied: 0
		};

		this.records = this.records.map((r) =>
			r.id === pay.id ? updatedPay : r
		);

		this.logAudit(
			isNsf ? "NSF" : "Voided",
			`Payment ${pay.id}`,
			`${pay.name} · reversed ${money(appliedAmt)} · reason ${isNsf ? "NSF" : reason}`
		);

		const voidId = this.nextId("VOID");
		const voidFields = {
			"Source Payment": pay.id,
			Reason: isNsf ? "NSF" : reason,
			"Void Date": voidDate,
			"Amount Reversed": money(appliedAmt),
			"Credit Cleared": money(unapplied),
			"Application ID": APP_ID
		};
		if (voidComment) voidFields.Comment = voidComment;

		this.addRecord(
			{
				id: voidId,
				type: "Void",
				name: `${isNsf ? "NSF" : "Void"} · ${pay.name}`,
				amount: pay.amount,
				status: isNsf ? "NSF" : "Voided",
				created: nowStamp(),
				fields: voidFields,
				notes:
					(voidComment ? voidComment + " · " : "") +
					(isNsf
						? "Payment reversal for NSF. Open NSF Alert to approve NSF fee."
						: "Payment voided as entered in error (or other non-NSF reason)."),
				sourcePayId: pay.id
			},
			true
		);

		if (isNsf) {
			const nsfFee = Number(this.voidNsfFee) || 45;
			const bankReason = (this.voidBankReason || "NSF").trim();
			const alertId = this.nextId("NSF");
			this.addRecord({
				id: alertId,
				type: "NSF Alert",
				name: alertId,
				amount: nsfFee,
				status: "Pending Approval",
				created: nowStamp(),
				fields: {
					"Source Payment": pay.id,
					"Original Payment Amount": money(pay.amount),
					"Bank Reason": bankReason,
					"NSF Fee": money(nsfFee),
					"BC Sync Status": "Pending Approval",
					"Application ID": APP_ID
				},
				notes:
					"Approve to assess NSF fee and queue details for Business Central (batch).",
				nsfFee,
				sourcePayId: pay.id
			});
		} else {
			this.toast(`Payment ${pay.name} voided`);
			this.syncInvoiceStatuses();
		}

		this.closeVoidModal();
	}

	approveNsf(id) {
		const alert = this.records.find(
			(r) => r.id === id && r.type === "NSF Alert"
		);
		if (!alert || alert.status !== "Pending Approval") return;

		const nsfFeeAmt = Number(alert.nsfFee || alert.amount || 45);
		const feeDef = FEE_CATALOG.find((f) => f.code === "FEE-NSF") || {
			name: "NSF Fee",
			code: "FEE-NSF",
			amount: nsfFeeAmt,
			category: "NSF Fee",
			gl: "4300-NSF",
			division: "All",
			description: "Fee assessed when a payment is returned NSF."
		};

		const feeId = this.nextId("FL");
		this.addRecord(
			{
				id: feeId,
				type: "Fee",
				name: feeDef.name,
				amount: nsfFeeAmt,
				status: "Assessed",
				created: nowStamp(),
				fields: {
					"Fee Code": feeDef.code,
					Category: feeDef.category,
					"GL Account": feeDef.gl,
					Division: feeDef.division,
					"Application ID": APP_ID,
					"Related NSF Alert": alert.id
				},
				notes: feeDef.description
			},
			true
		);

		const invId = this.nextId("INV");
		const issued = todayISO();
		const due = new Date(Date.now() + 14 * 86400000)
			.toISOString()
			.slice(0, 10);
		this.addRecord(
			{
				id: invId,
				type: "Invoice",
				name: invId,
				docName: `Invoice_${invId}.pdf`,
				amount: nsfFeeAmt,
				status: "Open",
				created: nowStamp(),
				fields: {
					"Fee Name": feeDef.name,
					"Fee Code": feeDef.code,
					Category: feeDef.category,
					Division: feeDef.division,
					"GL Account": feeDef.gl,
					"Issued Date": issued,
					"Due Date": due,
					"Bill To": APPLICANT,
					"Application ID": APP_ID,
					"Document Type": "PDF",
					"Related NSF Alert": alert.id
				},
				notes: "Invoice for NSF fee after approval.",
				relatedFeeId: feeId
			},
			true
		);

		this.records = this.records.map((r) => {
			if (r.id !== alert.id) return r;
			return {
				...r,
				status: "Approved",
				fields: {
					...r.fields,
					Approver: CURRENT_USER,
					"Approved Date": nowStamp(),
					"BC Sync Status": "Queued",
					"NSF Fee Invoice": invId
				},
				notes:
					"NSF fee assessed. Approved NSF details queued for Business Central (batch)."
			};
		});

		this.logAudit(
			"Approved",
			`NSF Alert ${alert.id}`,
			`NSF fee ${money(nsfFeeAmt)} assessed · BC sync Queued`,
			CURRENT_USER
		);

		this.toast(`NSF approved · Fee ${money(nsfFeeAmt)} assessed`);
		this.selectedId = alert.id;
		this.syncInvoiceStatuses();
	}

	/* Refund */
	openRefundModal() {
		if (this.credit <= 0) return;
		this.refundAmount = this.credit.toFixed(2);
		this.refundReason = "Overpayment";
		this.refundOtherReason = "";
		this.refundComment = "";
		this.refundMethod = "Cheque";
		this.showRefundModal = true;
	}

	closeRefundModal() {
		this.showRefundModal = false;
	}

	handleRefundMethodChange(event) {
		this.refundMethod = event.target.value;
	}

	handleRefundReasonChange(event) {
		this.refundReason = event.target.value;
		if (this.refundReason !== "Other") this.refundOtherReason = "";
	}

	handleRefundOtherReasonChange(event) {
		this.refundOtherReason = event.target.value;
	}

	handleRefundCommentChange(event) {
		this.refundComment = event.target.value;
	}

	saveRefund() {
		const amount = Number(this.refundAmount);
		if (!(amount > 0) || amount > this.credit + 0.001) {
			this.toast("Invalid refund amount");
			return;
		}
		let reason = this.refundReason;
		if (reason === "Other") {
			reason = (this.refundOtherReason || "").trim();
			if (!reason) {
				this.toast("Enter Other Reason");
				return;
			}
		}
		const refId = this.nextId("REF");
		const refundComment = (this.refundComment || "").trim();
		const refundFields = {
			Method: this.refundMethod,
			Reason: reason,
			"Application ID": APP_ID
		};
		if (refundComment) refundFields.Comment = refundComment;

		this.addRecord({
			id: refId,
			type: "Refund",
			name: refId,
			amount,
			status: "Pending",
			created: nowStamp(),
			fields: refundFields,
			notes:
				(refundComment ? refundComment + " · " : "") +
				"Pending approval. Open this record and click Approve Refund."
		});

		this.records = this.records.map((r) => {
			if (r.type === "Credit" && r.status === "Available") {
				return { ...r, status: "Pending Refund" };
			}
			return r;
		});
		this.credit = 0;
		this.closeRefundModal();
		this.syncInvoiceStatuses();
	}

	approveRefund(id) {
		const r = this.records.find((x) => x.id === id);
		if (!r || r.type !== "Refund") return;

		this.records = this.records.map((x) => {
			if (x.id === id) {
				return {
					...x,
					status: "Processed",
					fields: {
						...x.fields,
						Approver: CURRENT_USER,
						"Processed Date": nowStamp()
					},
					notes: "Refund approved and processed (AP cheque / EFT)."
				};
			}
			if (x.type === "Credit" && x.status === "Pending Refund") {
				return { ...x, status: "Refunded" };
			}
			return x;
		});

		this.logAudit(
			"Approved",
			`Refund ${r.id}`,
			`Refund ${money(r.amount)} processed`
		);
		this.toast(`Refund ${id} processed`);
		this.syncInvoiceStatuses();
	}

	/* Invoice */
	openInvoiceDoc(id) {
		const inv = this.records.find(
			(r) => r.id === id && r.type === "Invoice"
		);
		if (!inv) return;
		this.invoiceModalTitle = inv.docName;
		this.invoiceDoc = {
			id: inv.id,
			docName: inv.docName,
			status: inv.status,
			amountDisplay: money(inv.amount),
			feeName: inv.fields["Fee Name"],
			feeCode: inv.fields["Fee Code"],
			category: inv.fields.Category || "",
			division: inv.fields.Division || "",
			gl: inv.fields["GL Account"],
			issued: inv.fields["Issued Date"],
			due: inv.fields["Due Date"],
			applicant: APPLICANT,
			appId: APP_ID
		};
		this.showInvoiceModal = true;
	}

	closeInvoiceModal() {
		this.showInvoiceModal = false;
	}

	printInvoice() {
		window.print();
	}

	/* Detail actions */
	handleOpenInvoiceFromDetail() {
		if (this.selectedId) this.openInvoiceDoc(this.selectedId);
	}

	handleVoidFromDetail() {
		if (this.selectedId) this.openVoidModal(this.selectedId);
	}

	handleRefundFromDetail() {
		this.openRefundModal();
	}

	handleApproveNsf() {
		if (this.selectedId) this.approveNsf(this.selectedId);
	}

	handleApproveRefund() {
		if (this.selectedId) this.approveRefund(this.selectedId);
	}

	/* Reset */
	resetAll() {
		this.records = [];
		this.auditLog = [];
		this.applied = 0;
		this.credit = 0;
		this.selectedId = null;
		this.seq = 1;
		this.clearFeeForm();
		this.toast("Demo reset");
	}

	stopPropagation(event) {
		event.stopPropagation();
	}
}