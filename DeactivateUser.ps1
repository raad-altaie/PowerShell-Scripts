
function DeactivateUser($UserToDeactivate, $RandomPW) {
    try {
        #Reset the Password to the Random Password from Python 
        get-aduser $UserToDeactivate | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $RandomPW -force)

        #Disable the account in AD 
        Disable-ADAccount -Identity $UserToDeactivate

        $UserPath = ((Get-ADUser $UserToDeactivate -Properties *).CanonicalName).tostring()

        #Check if user not in 'Disabled Accounts' ou then set the Description for the disable time and path that user was at 
        if ( $UserPath -ne ('AutoAnything.local/AA Users/Disabled Accounts/'+(Get-ADUser $UserToDeactivate -Properties *).name.tostring()) ) {

            $Des = "Disabled on " + (Get-Date).tostring() + ", Moved from " + ((Get-ADUser $UserToDeactivate -Properties *).CanonicalName).tostring()

            Set-ADUser $UserToDeactivate -Description $Des

        }


        #Move the user to disabled accounts OU 
        Get-ADUser $UserToDeactivate | Move-ADObject -TargetPath 'OU=Disabled Accounts,OU=AA Users,DC=AutoAnything,DC=local'

        write-host User: *$UserToDeactivate* has been deactivated.   
    }
    catch {
        write-host $Error[0]
    }

}


#call the function to deactivate an account 
DeactivateUser $Username $RandomPassword
