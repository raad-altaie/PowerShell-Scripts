# Script to Create New User in Active Dirctory through PowerShell 

function CreateNewUser($FirstName, $LastName , $Title , $Manager, $UsertoCopyFrom ) {
    #make username (all lowercase)
    $Username = $FirstName.ToLower().ToCharArray()[0] + $LastName.ToLower()

    # Get OU Path from the user that we are copying from 
    $Path = ((Get-ADUser $UsertoCopyFrom -Properties *).DistinguishedName -split ",",2)[1]



    $Attributes = @{

        Enabled               = $true

        ChangePasswordAtLogon = $true
 
        # userlogon name (locally)
        UserPrincipalName     = $Username + '@CompanyName.local'
 
        #username
        Name                  = $Username
 
        # First Name
        GivenName             = $FirstName

 
        # Last Name
        Surname               = $LastName
 
        #Email
        EmailAddress           = $Username + '@companyname.com'  

        #login Script 
        ScriptPath            = 'script.bat'
 
        # Disply Nmae 
        DisplayName           = $FirstName + ' ' + $LastName
 
        # Description
        Description           = ''
 
        # Office
        Office                = ''
 
        # Company
        Company               = 'Company'
 
        # Department
        Department            = (Get-ADUser $UsertoCopyFrom -Properties *).Department
 
        # Title
        Title                 = $Title

        # Manager
        Manager               = $Manager
 
        AccountPassword       = "Password123" | ConvertTo-SecureString -AsPlainText -Force
    }
 
    #Create a user in AD on same OU as the CopyFromUser
    New-ADUser @Attributes -Path $Path

    #Change the Name to Display Name on CN in OU
    Set-ADUser $Username -PassThru | Rename-ADObject -NewName $Attributes.DisplayName


    #Copy the Groups from the Existing user in same Department 
    $grouplist = (Get-ADUser $UsertoCopyFrom -Properties memberof).memberof
    foreach ($group in $grouplist) {
        Add-ADGroupMember $group -Members $Username
    }  

    write-host User: $Username created and the password is: Password123  

}

# to create a user call the function e.g.
CreateNewUser 'FirstName' 'LastName' 'Job Title' 'MangerUsername' 'UsertoCopyFrom'


