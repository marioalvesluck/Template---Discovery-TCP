# Desenvolvido por Mario Alves - 25/01/2022 - By Step
# Monitoramento Windows TCP - Portas Established

# PARAMETROS
Param(

[String]$SELECT,
[String]$DADOS
)

# VARIAVEIS DO AMBIENTE

#VARIAVEL DE COLETA DAS PROPRIEDADES DO COMANDO
$TCP_CONECT = Get-NetTCPConnection -State Established | Where-Object {$_.OwningProcess -eq $DADOS} |Select-Object -Property LocalAddress, LocalPort,RemoteAddress,RemotePort,State,AppliedSetting,OwningProcess,@{name='RemoteHostName';expression={(Resolve-DnsName $_.RemoteAddress).NameHost}},@{name='ProcessName';expression={(Get-Process -Id $_.OwningProcess).ProcessName}},@{name='CPU';expression={(Get-Process -Id $_.OwningProcess).CPU}},@{name='Id';expression={(Get-Process -Id $_.OwningProcess).Id}},@{name='WS';expression={(Get-Process -Id $_.OwningProcess).WS}}
# VARIAVEL PARA COLETA PARA MONTAR JSON
$PROCESS = Get-NetTCPConnection -State Established |Select-Object -Property OwningProcess,@{name='ProcessName';expression={(Get-Process -Id $_.OwningProcess).ProcessName}}
 
# CRIAR DISCOVERY E MONTAR JSON
if ($SELECT -eq 'JSON')
{
$count = 1
write-host "{"
write-host " `"data`":[`n"
foreach ($OBJETO in $PROCESS )
{
    #$i++
    if ($COUNT -lt $PROCESS.Count)
{
$LINE= "{ `"{#NAME}`":`"" + $OBJETO.ProcessName + "`",`"{#PID}`":`"" + $OBJETO.OwningProcess + "`"},"
write-host $LINE
}
elseif ($COUNT -ge $PROCESS.Count)
{
$LINE= "{ `"{#NAME}`":`"" + $OBJETO.ProcessName + "`",`"{#PID}`":`"" + $OBJETO.OwningProcess + "`"}"
write-host $LINE
}
$COUNT++;
}
write-host
write-host " ]"
write-host "}"
}

#FUNÇÃO PARA COLETAR NOME DA CONEXAO

if ( $SELECT -eq 'REMOTEHOSTNAME' )
{
    write-host $TCP_CONECT.RemoteHostName
}
# FUNÇÃO PARA COLETAR PORTA LOCAL
if ( $SELECT -eq 'LOCALPORT' )
{
  write-host $TCP_CONECT.LocalPort
}
# FUNÇÃO PARA COLETAR PORTA REMOTA
if ( $SELECT -eq 'REMOTEPORT' )
{
  write-host $TCP_CONECT.RemotePort
}
# FUNÇÃO PARA COLETAR IP REMOTO
if ( $SELECT -eq 'REMOTEADDRESS' )
{
  write-host $TCP_CONECT.RemoteAddress
}
# FUNÇÃO PARA COLETAR IP LOCAL
if ( $SELECT -eq 'LOCALADDRESS' )
{
  write-host $TCP_CONECT.LocalAddress
}

# TIPO DE CONEXAO DE REDE
if ( $SELECT -eq 'APPLIEDSETTING' )
{
  write-host $TCP_CONECT.AppliedSetting
}

#FUNÇÃO PARA COLETAR ESTADO
if ( $SELECT -eq 'TYPESTATE' )
{
  write-host $TCP_CONECT.State
}

#FUNÇÃO PARA COLETAR TEMPO DE CPU DO PROCESSO
if ( $SELECT -eq 'CPU' )
{
  $TCP_CONECT | Where-Object { $_.OwningProcess -eq $DADOS } | Select-Object CPU |select-object -ExpandProperty CPU | select-object -First 1
}

#FUNÇÃO PARA COLETAR UTILIZACAO DE MEMÓRIA DO PROCESSO
if ( $SELECT -eq 'WS' )
{
  $TCP_CONECT | Where-Object { $_.OwningProcess -eq $DADOS } | Select-Object WS |select-object -ExpandProperty WS | select-object -First 1
}

#FUNÇÃO PARA COLETAR PORCENTAGEM CPU UTILIZADA
if ( $SELECT -eq 'PERCENTCPU' )
{
(get-wmiobject Win32_PerfFormattedData_PerfProc_Process | Where-Object { $_.IDProcess -eq $DADOS } | Select-Object).PercentProcessorTime
}

# Quantidade Portas Estado Listen
if ( $SELECT -eq 'QLISTEN' )
{
  $jobs = Get-NetTCPConnection -State Listen | Measure-Object | ForEach-Object{$_.Count}
  write-host ([int]$jobs)
}
# Quantidade Portas Estado Bound
if ( $SELECT -eq 'QBOUND' )
{
  $jobs = Get-NetTCPConnection -State bound | Measure-Object | ForEach-Object{$_.Count}
  write-host ([int]$jobs)
}

# Quantidade Portas Estado Espera
if ( $SELECT -eq 'QTIMEWAIT' )
{
  $jobs = Get-NetTCPConnection -State TimeWait | Measure-Object | ForEach-Object{$_.Count}
  write-host ([int]$jobs)
}

# Quantidade Portas Estado Established
if ( $SELECT -eq 'QESTABLISHED' )
{
  $jobs = Get-NetTCPConnection -State Established | Measure-Object | ForEach-Object{$_.Count}
  write-host ([int]$jobs)
}

# Quantidade Portas Estado Fechar / Aguardar
if ( $SELECT -eq 'QCLOSEWAIT' )
{
  $jobs = Get-NetTCPConnection -State CloseWait | Measure-Object | ForEach-Object{$_.Count}
  write-host ([int]$jobs)
}

# Quantidade Portas Estado SynSent
if ( $SELECT -eq 'QSYNSENT' )
{
  $jobs = Get-NetTCPConnection -State SynSent | Measure-Object | ForEach-Object{$_.Count}
  write-host ([int]$jobs)
}

# Usuarios Conectados 
if ( $SELECT -eq 'USERACTIVE' )
{
  $jobs = Get-CimInstance -ClassName Win32_ComputerSystem -Property UserName
  $USERNAME = $jobs.UserName | ForEach-Object {$_.Split("\")} | Select-Object -Last 1
  write-host $USERNAME
}

# FUNÇÃO PARA COLETAR LOCALIZAÇÂO o PAIS
if ( $SELECT -eq 'COUNTRY' )
{
$DADOS = $TCP_CONECT.RemoteAddress
  $JOBS = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$DADOS"
  write-host $JOBS.country
}
# FUNÇÃO PARA COLETAR LOCALIZAÇÂO o PAIS
if ( $SELECT -eq 'COUNTRYCODE' )
{
$DADOS = $TCP_CONECT.RemoteAddress
  $JOBS = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$DADOS"
  write-host $JOBS.countryCode
}

# FUNÇÃO PARA COLETAR LOCALIZAÇÂO REGIAO PAíS
if ( $SELECT -eq 'REGIONNAME' )
{
$DADOS = $TCP_CONECT.RemoteAddress
  $JOBS = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$DADOS"
  write-host $JOBS.regionName
}


# FUNÇÃO PARA COLETAR LOCALIZAÇÂO REGIAO PAíS
if ( $SELECT -eq 'REGION' )
{
$DADOS = $TCP_CONECT.RemoteAddress
  $JOBS = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$DADOS"
  write-host $JOBS.region
}


# FUNÇÃO PARA COLETAR LOCALIZAÇÂO CIDADE PAíS
if ( $SELECT -eq 'CITY' )
{
$DADOS = $TCP_CONECT.RemoteAddress
  $JOBS = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$DADOS"
  write-host $JOBS.city
}

# FUNÇÃO PARA COLETAR LOCALIZAÇÂO ZIP PAíS
if ( $SELECT -eq 'ZIP' )
{
$DADOS = $TCP_CONECT.RemoteAddress
  $JOBS = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$DADOS"
  write-host $JOBS.zip
}

# FUNÇÃO PARA COLETAR LOCALIZAÇÂO LATITUDE PAíS
if ( $SELECT -eq 'LATITUDE' )
{
$DADOS = $TCP_CONECT.RemoteAddress
  $JOBS = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$DADOS"
  write-host $JOBS.lat
}


# FUNÇÃO PARA COLETAR LOCALIZAÇÂO LONGITUDE PAíS
if ( $SELECT -eq 'LONGITUDE' )
{
$DADOS = $TCP_CONECT.RemoteAddress
  $JOBS = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$DADOS"
  write-host $JOBS.lon
}


# FUNÇÃO PARA COLETAR LOCALIZAÇÂO TIMEZONE PAíS
if ( $SELECT -eq 'TIMEZONE' )
{
$DADOS = $TCP_CONECT.RemoteAddress
  $JOBS = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$DADOS"
  write-host $JOBS.timezone
}


# FUNÇÃO PARA COLETAR LOCALIZAÇÂO ISP PAíS
if ( $SELECT -eq 'ISP' )
{
$DADOS = $TCP_CONECT.RemoteAddress
  $JOBS = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$DADOS"
  write-host $JOBS.isp
}


# FUNÇÃO PARA COLETAR LOCALIZAÇÂO ORG PAíS
if ( $SELECT -eq 'ORG' )
{
$DADOS = $TCP_CONECT.RemoteAddress
  $JOBS = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$DADOS"
  write-host $JOBS.org
}

# FUNÇÃO PARA COLETAR LOCALIZAÇÂO AS PAíS
if ( $SELECT -eq 'AS' )
{
$DADOS = $TCP_CONECT.RemoteAddress
  $JOBS = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$DADOS"
  write-host $JOBS.as
}