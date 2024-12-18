# useful Telegram information
$token = "confidential"
$imgg = "confidential"
$imgg = "confidential"
$george = "confidential"
$coders = "confidential"

function sendMsg 
{
    param 
    (
        [string]$text
    )

    if ($stream -eq $imgg)
    {
        $null = Invoke-WebRequest "https://api.telegram.org/bot$token/sendMessage?chat_id=$stream&text=$text&message_thread_id=2" -ErrorAction Stop;
    }
    else
    {
        $null = Invoke-WebRequest "https://api.telegram.org/bot$token/sendMessage?chat_id=$stream&text=$text" -ErrorAction Stop
    }
}

function toString 
{
    param
    (
        $slot
    )

    $str = [string]$slot
    $str = $str.Substring($str.IndexOf("=") + 1)
    $str = $str.Substring(0, $str.Length - 1)

    return $str
}

# commented venues are no longer available
$venuesCentral = 
@(
    "Whampoa"
    # "Toa Payoh Central",
    "Bidadari"
    "Toa Payoh East",
    "Toa Payoh South"
    "Toa Payoh West",
    "Bishan",
    "Marymount",
    # "Yio Chu Kang"
    "Braddell Heights"
    "Kebun Baru",
    "Teck Ghee"
)







# api limited to 10 requests per min
$venuesEast =
@(
    "Tampines Changkat",
    "Tampines East",
    "Tampines North",
    "Bedok",
    "Fengshan",
    "Eunos",
    "Kaki Bukit",
    "Siglap",
    "Changi Simei",
    "Kallang"
)

$date = $null
$region = $null
$fullVenues = $null
$msg = $null
$isError = $true

while (-not($stream -eq "1" -or $stream -eq "2" -or $stream -eq "3"))
{
    $stream = Read-Host -Prompt "1: george`n2: imgg`n3: coders`nstream"
}

if ($stream -eq "1")
{
    $stream = $george
}
elseif ($stream -eq "2")
{
    $stream = $imgg
}
elseif ($stream -eq "3")
{
    $stream = $coders
}

while ($isError)
{
    $date = Read-Host -Prompt "Date"

    try
    {
        if ([int]$date -ge (Get-Date).day)
        {
            $date = "{0:D2}" -f $date
            $month = "{0:D2}" -f (Get-Date).Month
            $date = "$date/$month/$((Get-Date).Year)"
        }
        else
        {
            $date = "{0:D2}" -f [int]$date
            $month = "{0:D2}" -f ((Get-Date).Month + 1)
            $date = "$date/$month/$((Get-Date).Year)"
        }

        $isError = $false
    }
    catch
    {
        Write-Host "Not a number!" -ForegroundColor Red
    }
}

while (-not($region -eq "1" -or $region -eq "2"))
{
    $region = Read-Host -Prompt "1: Central`n2: East`nLocation"
}

if ($region -eq "1")
{
    $venues = $venuesCentral
    $region = "central"
}
elseif ($region -eq "2")
{
    $venues = $venuesEast
    $region = "east"
}

foreach ($venue in $venues)
{
    $isFull = $true
    $heading = $venue
    $venue = $venue.Replace(" ", "").ToLower()
    $courtsMsg = $null
    
    try
    {
        $courts = ((Invoke-WebRequest -UseBasicParsing -Uri "https://www.onepa.gov.sg/pacesapi/facilityavailability/GetFacilitySlots?selectedFacility=$($venue)cc_badmintoncourts&selectedDate=$($date)").Content | Convertfrom-Json).response.resourceList
    }
    catch
    {
        exit
    }

    for ($i = 0; $i -lt $courts.Count; ++$i)
    {
        $slots = $courts[$i].slotList | Where-Object {$_.availabilityStatus -eq "Available"} | Select-Object {$_.timeRangeName}
        
        # had bug where if $slots has 1 item $slots.Count will be null
        if ($slots.Count -eq 0)
        {
            if ($i + 1 -eq $courts.Count -and $isFull)
            {
                $fullVenues += "$heading, "
            }

            continue
        }
        else
        {
            $isFull = $false
        }

        if ($i + 1 -eq $courts.Count)
        {
            $courtsStr = $null
            if ($courts.Count -eq 1)
            {
                $courtsStr = "court"
            }
            else
            {
                $courtsStr = "courts"
            }
            $msg += "`n$heading ($($courts.Count) $courtsStr)`n------------------------`n"
        }
        
        $firstStartTime = $null
        $prevEndTime = $null
        $startTime = $null
        $endTime = $null
        
        for ($j = 0; $j -lt @($slots).Count; ++$j)
        {
            $str = toString $slots[$j]
            $startTime = $str.Substring(0, $str.IndexOf(" -"))
            $endTime = $str.Substring($str.IndexOf("- ") + 2)

            if ($null -eq $firstStartTime)
            {
                $firstStartTime = $startTime
            }
            elseif (-not ($startTime -eq $prevEndTime))
            {
                $courtsMsg += "$firstStartTime - $prevEndTime (court $($i + 1))`n"
                $firstStartTime = $startTime
            }
            
            if ($j + 1 -eq @($slots).Count)
            {
                $courtsMsg += "$firstStartTime - $endTime (court $($i + 1))`n"
            }

            $prevEndTime = $endTime
        }
    }
    
    $msg += $courtsMsg
}

sendMsg "Available slots on $date ($(([datetime]::ParseExact($date, "dd/MM/yyyy", $null)).DayOfWeek)) in $region region"
if ($fullVenues.Length)
{
    $msg += "`nFully booked venues: $($fullVenues.Substring(0, $fullVenues.Length - 2))"
}
sendMsg $msg
sendMsg "Brought to you by GCC-bot"