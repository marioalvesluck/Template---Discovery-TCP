# Desenvolvido por Mario Alves - 25/01/2022 - By Step
# Monitoramento Windows TCP - Portas Established

#VARIAVEIS PARA COLETA
Param(

[String]$SELECT,
[String]$DADOS
)

$CONEXTION =  Get-NetTCPConnection -State Established
$TCP_CONECT = $CONEXTION | Where-Object {$_.OwningProcess -eq $DADOS} |Select-Object -Property LocalAddress, LocalPort,RemoteAddress,RemotePort,State,AppliedSetting,OwningProcess,@{name='RemoteHostName';expression={(Resolve-DnsName $_.RemoteAddress).NameHost}},@{name='ProcessName';expression={(Get-Process -Id $_.OwningProcess).ProcessName}},@{name='CPU';expression={(Get-Process -Id $_.OwningProcess).CPU}},@{name='Id';expression={(Get-Process -Id $_.OwningProcess).Id}},@{name='WS';expression={(Get-Process -Id $_.OwningProcess).WS}}

# LISTA DE PROCESSOS
$PROCESS = $CONEXTION |Select-Object -Property OwningProcess,@{name='ProcessName';expression={(Get-Process -Id $_.OwningProcess).ProcessName}}

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

if ( $SELECT -eq 'LOCALPORT' )
{
  write-host $TCP_CONECT.LocalPort
}

if ( $SELECT -eq 'REMOTEPORT' )
{
  write-host $TCP_CONECT.RemotePort
}

if ( $SELECT -eq 'REMOTEADDRESS' )
{
  write-host $TCP_CONECT.RemoteAddress
}

if ( $SELECT -eq 'LOCALADDRESS' )
{
  write-host $TCP_CONECT.LocalAddress
}

if ( $SELECT -eq 'APPLIEDSETTING' )
{
  write-host $TCP_CONECT.AppliedSetting
}
if ( $SELECT -eq 'TYPESTATE' )
{
  write-host $TCP_CONECT.State
}
# TEMPO de ULTILIZACAO
if ( $SELECT -eq 'CPU' )
{
  write-host $TCP_CONECT.CPU
}

#MEMORIA
if ( $SELECT -eq 'WS' )
{
  write-host $TCP_CONECT.WS
}

# CONSUMO DE CPU EM %
if ( $SELECT -eq 'PERCENTCPU' )
{
(get-wmiobject Win32_PerfFormattedData_PerfProc_Process | Where-Object { $_.IDProcess -eq $DADOS } | Select-Object).PercentProcessorTime
}

# Quantidade Portas Estado Listen
if ( $SELECT -eq 'QLISTEN' )
{
  $jobs = Get-NetTCPConnection -State Listen | Measure-Object | ForEach-Object{$_.Count}
  write-host $jobs
}
# Quantidade Portas Estado Bound
if ( $SELECT -eq 'QBOUND' )
{
  $jobs = Get-NetTCPConnection -State bound | Measure-Object | ForEach-Object{$_.Count}
  write-host $jobs
}

# Quantidade Portas Estado Espera
if ( $SELECT -eq 'QTIMEWAIT' )
{
  $jobs = Get-NetTCPConnection -State TimeWait | Measure-Object | ForEach-Object{$_.Count}
  write-host $jobs
}

# Quantidade Portas Estado Established
if ( $SELECT -eq 'QESTABLISHED' )
{
  $jobs = Get-NetTCPConnection -State Established | Measure-Object | ForEach-Object{$_.Count}
  write-host $jobs
}

# Quantidade Portas Estado Fechar / Aguardar
if ( $SELECT -eq 'QCLOSEWAIT' )
{
  $jobs = Get-NetTCPConnection -State CloseWait | Measure-Object | ForEach-Object{$_.Count}
  write-host $jobs
}

# Quantidade Portas Estado SynSent
if ( $SELECT -eq 'QSYNSENT' )
{
  $jobs = Get-NetTCPConnection -State SynSent | Measure-Object | ForEach-Object{$_.Count}
  write-host $jobs
}