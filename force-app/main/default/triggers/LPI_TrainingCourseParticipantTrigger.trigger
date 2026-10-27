/**
 * @author       : Hiten Aggarwal
 * @description  : This is trigger on TrainingCourseParticipant object
 * @since        : 09-Jan-2023
 */
trigger LPI_TrainingCourseParticipantTrigger on TrainingCourseParticipant (After Insert,Before Insert, After Update, Before Update, After Delete, Before Delete, After Undelete) {
    LPI_TriggerConfiguration__mdt tcmdt = LPI_TriggerConfiguration__mdt.getInstance('Trigger_Configuration');
    if(tcmdt.TrainingCourseParticipant__C){
        new LPI_TrainingCourseParticipantTrgHndlr().run();
    }
}