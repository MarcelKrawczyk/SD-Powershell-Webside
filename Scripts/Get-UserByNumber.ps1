function Get-UserByNumber {
    param (
        [string]$FullNumber  # Pelny numer, np. +48123123123
    )

    # Lista znanych prefiksow krajow
    $knownPrefixes = @(
        "+998", "+996", "+995", "+994", "+993", "+992", "+977", "+976", "+975", "+974", "+973", "+972", 
		"+971", "+970", "+968", "+967", "+966", "+965", "+964", "+963", "+962", "+961", "+960", "+886", 
		"+880", "+870", "+856", "+855", "+853", "+852", "+850", "+692", "+691", "+690", "+689", "+688", 
		"+687", "+686", "+685", "+683", "+682", "+681", "+680", "+679", "+678", "+677", "+676", "+675", 
		"+674", "+673", "+672", "+670", "+599", "+598", "+597", "+596", "+595", "+594", "+593", "+592", 
		"+591", "+590", "+509", "+508", "+507", "+506", "+505", "+504", "+503", "+502", "+501", "+500", 
		"+423", "+421", "+420", "+389", "+387", "+386", "+385", "+382", "+381", "+380", "+378", "+377", 
		"+376", "+375", "+374", "+373", "+372", "+371", "+370", "+359", "+358", "+357", "+356", "+355", 
		"+354", "+353", "+352", "+351", "+350", "+299", "+298", "+297", "+291", "+290", "+269", "+268", 
		"+267", "+266", "+265", "+264", "+263", "+262", "+261", "+260", "+258", "+257", "+256", "+255", 
		"+254", "+253", "+252", "+251", "+250", "+249", "+248", "+246", "+245", "+244", "+243", "+242", 
		"+241", "+240", "+239", "+238", "+237", "+236", "+235", "+234", "+233", "+232", "+231", "+230", 
		"+229", "+228", "+227", "+226", "+225", "+224", "+223", "+222", "+221", "+220", "+218", "+216", 
		"+213", "+212", "+98", "+95", "+94", "+93", "+92", "+91", "+90", "+86", "+84", "+82", "+81", 
		"+66", "+65", "+64", "+63", "+62", "+61", "+60", "+58", "+57", "+56", "+55", "+54", "+53", 
		"+52", "+51", "+49", "+48", "+47", "+46", "+45", "+44", "+43", "+41", "+40", "+39", "+36", 
		"+34", "+33", "+32", "+31", "+30", "+27", "+20", "+7", "+1"
    )

    # Pomiar czasu start
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        $ErrorActionPreference = "Stop"

        # Znajdz najdluzszy pasujacy prefiks
        $AreaCode = $null
        foreach ($prefix in $knownPrefixes) {
            if ($FullNumber.StartsWith($prefix)) {
                $AreaCode = $prefix
                break
            }
        }

        if (-not $AreaCode) {
            $result = @{ error = "Raptor404" }
        } else {
            # Oddziel kierunkowy od numeru
            $PhoneNumber = $FullNumber.Substring($AreaCode.Length)
            $fullSearchNumber = "$AreaCode*$PhoneNumber"

            # Szukaj uzytkownikow
            $users = @(Get-QADUser -LdapFilter "(|(mobile=$fullSearchNumber)(othermobile=$fullSearchNumber)(telephonenumber=$fullSearchNumber))")

            if ($users.Count -gt 0) {
                $usernames = $users | Select-Object -ExpandProperty SamAccountName
                $result = @{ users = $usernames }
            } else {
                $result = @{ error = "Raptor404" }
            }
        }
    }
    catch {
        $result = @{ error = "Raptor404" }
    }

    # Stop pomiaru czasu i dodanie do wyniku
    $stopwatch.Stop()
    $result.duration = [math]::Round($stopwatch.Elapsed.TotalSeconds, 3)

    # Zwroc wynik jako JSON
    $result | ConvertTo-Json -Depth 2


}

# === Automatyczne wywolanie, jesli podano argument ===
if ($MyInvocation.InvocationName -ne '.' -and $args.Count -eq 1) {
    Get-UserByNumber -FullNumber $args[0]
    }
    
# Get-UserByNumber "+48123123123"
