#Setting the path for hash database and target folder
$HashDatabase = "C:\Users\abhay\Documents\2020\Test\HashStorage\database.xml"
$Target = "C:\Users\abhay\Documents\2020\Test\zipped\"

# Zipping individual files using windows default zip program
dir | ForEach-Object { 
& Compress-Archive -Force -DestinationPath ($Target+$_.Name+".zip") -Path $_.Name 
}

#Calculating base-64 encoded md5 hash value
#Get-FileHash -Algorithm MD5 -Path (Get-ChildItem "$Targe*.*" -Recurse)

#Loopthrough all the files in zip folder
Get-ChildItem $Target -Filter *.zip | 
Foreach-Object {
    $dest = $_.FullName
    $object = $_.Name
    Write-Host $dest
    Write-Host $object

#Getting the MD5 hash value

$hash = CertUtil -hashfile  "$dest" MD5| findstr -vrc:"[^0123-9aAb-Cd-EfF ]"
Write-Host $hash

#Getting the MD5 base64 encoded hash value

$hasher = [System.Security.Cryptography.MD5]::Create()
$content = Get-Content -Encoding byte $dest
$base64hash = [System.Convert]::ToBase64String($hasher.ComputeHash($content))
Write-Host $base64hash

# Uploading the file to s3 if the MD5 hash matches the database
aws s3api put-object --bucket s3-winscp --key $object --body $dest --content-md5 $base64hash --metadata md5checksum=$hash
}
