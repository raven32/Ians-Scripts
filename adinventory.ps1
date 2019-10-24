 #get date for saving computer to append to .csv file under path
$RptDate = Get-Date -Format m;
#use Distinguised Name of OU
$OU = "OU=SandBox,OU=IET-New,OU=DEPARTMENTS,DC=ou,DC=ad3,DC=ucdavis,DC=edu"
#output path of reprot scan
$RptPath = "C:\1\"

get-adobject -Identity $OU | Out-Null

$searchpath = Get-ChildItem -path ad:\$OU -Recurse 
$ADsearh = @()

$output = foreach ($object in $searchpath) {
        $aditem = Get-ADObject -Identity $object -Properties *
   
         
      $item = [PSCustomObject]@{
       
    Name = ''
    DistinguishedName = ''
    LastLogonDate = ''
    ObjectClass = ''
    OperatingSystem = ''
    Modified = ''   
    }
    $item.ObjectClass = $object.ObjectClass
    $item.Name = $object.Name
    $item.DistinguishedName = $object.DistinguishedName
    $item.Modified = $aditem.Modified
    $item.OperatingSystem = $aditem.OperatingSystem
    

    If ($aditem.ObjectClass -eq "Computer"){   
            $adcomputer = get-adcomputer -Identity $object -Properties *
            $item.LastLogonDate = $adcomputer.LastLogonDate
    }
    
        $ADsearh += $item


} 

$ADsearh | Export-Csv ($RptPath + ($RptDate + (" AD OU Search" + ".csv"))) -NoTypeInformation 
