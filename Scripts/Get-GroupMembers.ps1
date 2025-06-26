function Get-GroupMembers {
    param(
        [Parameter(Position=0)]
        [string]$GroupName # Dokladny cn ldapname grupy 
    )

    # Pomiar czasu
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        $ErrorActionPreference = "Stop"

        # Wyszukaj grupe po nazwie (LDAP filter)
        $group = Get-QADGroup -LdapFilter "(name=$GroupName)"

        if ($group) {
            # Pobierz czlonkow tej grupy i ich SAMAccountName
            $members = Get-QADGroupMember -Identity $group.DN |
                       Select-Object -ExpandProperty SAMAccountName

            if ($members) {
                $result = @{ users = $members }
            } else {
                $result = @{ error = "1Raptor404" }
            }
        } else {
            $result = @{ error = "2Raptor404" }
        }
    }
    catch {
        $result = @{ error = "3Raptor404" }
    }

    # Zatrzymaj stoper i dodaj czas wykonania
    $stopwatch.Stop()
    $result.duration = [math]::Round($stopwatch.Elapsed.TotalSeconds, 3)

    # Zwroc wynik jako JSON
    $result | ConvertTo-Json -Depth 2
}
# === Automatyczne wywolanie, jesli podano argument ===
if ($MyInvocation.InvocationName -ne '.' -and $args.Count -eq 1) {
    Get-GroupMembers -GroupName $args[0]
}
# Get-GroupMembers "group.name"
# Cudzyslow jest wymagany, jesli nazwa grupy zawiera spacje
