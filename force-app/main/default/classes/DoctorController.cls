public class DoctorController {
    
    public String choosenApp {get; set;}
    public String userID = UserInfo.getUserId();
    User user = database.query('Select FirstName, LastName From User Where ID=:UserID Limit 1');
    String userLastName = user.LastName;
   	public Doctor__c doctor = database.query('Select Name, ID, First_Name__c, Last_Name__c, Specialty__c, Email__c From Doctor__c Where Last_Name__c=:userLastName Limit 1');
    public Appointment__c returnedApp {Get; Set { returnedApp = value; }}
    public Boolean isRendered;
    public String cancellationMessage {get; set;}
    List<Residence__c> doctorResidences;
    
    // show input rejection box
    public void displayRejectionInput(){
        setIsRendered(true);
    }
    // controlling input field for doctor to entire cancellation message
    public Boolean getIsRendered(){
        return this.isRendered;
    }
    public void setIsRendered(){
        this.isRendered = false;
    }
    public void setIsRendered(Boolean isRendered){
        this.isRendered = isRendered;
    }

    public List<Residence__c> getDoctorResidences(){
        String docFirstName = doctor.First_Name__c;
        String docLastName = doctor.Last_Name__c;
        List<Residence__c> testRes = Database.query('SELECT Id, Office_Location__r.Name FROM Residence__c WHERE Doctor__r.First_Name__c=:docFirstName AND Doctor__r.Last_Name__c=:docLastName');
        return testRes;
    }
    
    // Query for Docter using last name of the user logged in
    public List<Doctor__c> GetDoctor() {
        List<Doctor__c> docList = database.query('Select First_Name__c, Last_Name__c, Specialty__c, Email__c From Doctor__c Where Last_Name__c=:userLastName');
    	return docList;
    }
    
    // Query for Appointments using name of the doctor assiated with the user logged in
    // Sort the Query by Start time and dont show any appointments already past
    public List<Appointment__c> GetApprovedAppointments() {
        ID docID = doctor.ID;
        datetime present = system.now();
        String confirmed = 'Confirmed';
        List<Appointment__c> appList = database.query('Select Name, Start_Time__c, Customer__r.FullName__c, Description__c, Location__r.Office_Location__r.Name From Appointment__c Where Doctor__c=:docID AND Start_Time__c >:present AND Status__c=:confirmed');
        return appList;
    }
    
    public List<SelectOption> GetPendingAppointments() {
           	ID docID = doctor.Id;
            datetime present = system.now();
            String pending = 'Pending';
            List<Appointment__c> appList = database.query('Select Id From Appointment__c Where Doctor__c=:docID AND Start_Time__c >:present AND Status__c=:pending');
            List<SelectOption> appNames = new List<SelectOption>();
            for (Appointment__c app : appList) {
                appNames.add(new SelectOption(app.ID, app.ID));
            }
            return appNames;
    }
    
    public void ViewAppointmentDetails() {
        if (choosenApp == null) {
        	List<Appointment__c> appList = database.query('Select Name, Start_Time__c, End_Time__c, Customer__r.FullName__c, Description__c, Status__c, Location__r.Name From Appointment__c');            
        	Appointment__c app = appList[0];
            returnedApp = app;
        
        } else {
            ID appID = (ID) choosenApp;
        	Appointment__c app = database.query('Select Name, Start_Time__c, End_Time__c, Customer__r.FullName__c, Description__c, Status__c, Location__r.Name From Appointment__c Where Id=:appID');
    		returnedApp = app;
        }
	}
    
    //Status updates to Confirmed
    public void AcceptAppointment() {
        ID appID = (ID) choosenApp;
        Appointment__c app = database.query('Select Name, Start_Time__c, End_Time__c, Customer__r.FullName__c, Description__c, status__c From Appointment__c Where Id=:appID');
        app.Status__c = 'Confirmed';
        update app;
    }
    
    //Status updates to Cancelled
    public void CancelAppointment() {
        if(this.cancellationMessage != ''){
            ID appID = (ID) choosenApp;
            Appointment__c app = database.query('Select Name, Start_Time__c, End_Time__c, Customer__r.FullName__c, Description__c, status__c From Appointment__c Where Id=:appID');
            app.Status__c = 'Cancelled';
            app.Description__c = app.Description__c + '\n Cancellation Message: ' + this.cancellationMessage;
            update app;
        }

    }
}