#!../../bin/linux-x86_64/tpmac

< envPaths

epicsEnvSet("ENGINEER",  "kgofron x5283")
epicsEnvSet("LOCATION",  "740 IXS RG:D1")
epicsEnvSet("STREAM_PROTOCOL_PATH", ".:../protocols:$(PMACUTIL)/protocol")

epicsEnvSet("P",         "XF:10IDD-OP")
epicsEnvSet("TP_PORT",   "P0")
# epicsEnvSet("IOCNAME",   "mc8")
#epicsEnvSet("IOC_PREFIX", "$(P){IOC:$(IOCNAME)}")
epicsEnvSet("MC",   "MC:18")
epicsEnvSet("CT",   "XF:10IDD-CT")
epicsEnvSet("IOC_PREFIX", "$(CT){IOC-$(MC)}")
epicsEnvSet("MC_PREFIX", "$(CT){$(MC)}")

epicsEnvSet("EPICS_CA_AUTO_ADDR_LIST", "NO")
epicsEnvSet("EPICS_CA_ADDR_LIST", "10.10.0.255")

cd ${TOP}

## Register all support components
dbLoadDatabase("dbd/tpmac.dbd",0,0)
tpmac_registerRecordDeviceDriver(pdbbase)

# pmacAsynIPConfigure() is a wrapper for drvAsynIPPort::drvAsynIPPortConfigure() and
# pmacAsynIPPort::pmacAsynIPPortConfigureEos().
# See pmacAsynIPPort.c
#pmacAsynIPConfigure("$(TP_PORT)", "xf10idd-mc3:1025")
pmacAsynIPConfigure("$(TP_PORT)", "10.10.2.118:1025")
# WARNING: a trace-mask of containing 0x10 will TRACE_FLOW (v. noisy!!)
#asynSetTraceMask("$(TP_PORT)",-1,0x9)
#asynSetTraceIOMask("$(TP_PORT)",-1,0x2)

# pmacAsynMotorCreate(port,addr,card,nAxes)
# see pmacAsynMotor.c
pmacAsynMotorCreate("$(TP_PORT)", 0, 1, 8);

# Setup the motor Asyn layer (port, drvet name, card, nAxes+1)
drvAsynMotorConfigure("M0", "pmacAsynMotor", 1, 9)

# Initialize the coord-system(port,addr,cs,ref,prog#)
# pmacAsynCoordCreate("$(TP_PORT)",0,1,1,10)
# pmacAsynCoordCreate("$(TP_PORT)",0,2,2,10)
pmacAsynCoordCreate("$(TP_PORT)",0,2,2,10)

# setup the coord-sys(portName,drvel-name,ref#(from create),nAxes+1)
# drvAsynMotorConfigure("CS1","pmacAsynCoord",1,9)
# drvAsynMotorConfigure("CS2","pmacAsynCoord",2,9)
drvAsynMotorConfigure("CS2","pmacAsynCoord",2,9)

# change poll rates (card, poll-period in ms)
pmacSetMovingPollPeriod(1, 100)
pmacSetIdlePollPeriod(1, 1000)
pmacSetCoordMovingPollPeriod(5,200)
pmacSetCoordIdlePollPeriod(5,2000)

# Set coordinate system scaling
# Default value is 10000
# pmacSetCoordStepsPerUnit(CS,CS_axis, scaling_factor)
pmacSetCoordStepsPerUnit(2, 6, 128000)
pmacSetCoordStepsPerUnit(2, 7, 25196.8503937)

## Load record instances
dbLoadTemplate("db/motor.substitutions")
dbLoadTemplate("db/motorstatus.substitutions")
dbLoadTemplate("db/pmacStatus.substitutions")
dbLoadTemplate("db/pmac_asyn_motor.substitutions")
dbLoadTemplate("db/autohome.substitutions")
dbLoadTemplate("db/cs.substitutions")
dbLoadRecords("db/motorUtil.db","P=$(MC_PREFIX)")
dbLoadRecords("db/asynComm.db","P=$(MC_PREFIX),PORT=$(TP_PORT),ADDR=0")
dbLoadRecords("$(TOP)/iocBoot/$(IOC)/write_var.db","P=$(IOC_PREFIX),R=AirOn,PORT=$(TP_PORT),ADDR=0,VAR=M32")

## autosave/restore machinery
save_restoreSet_Debug(0)
save_restoreSet_IncompleteSetsOk(1)
save_restoreSet_DatedBackupFiles(1)

set_savefile_path("${TOP}/as","/save")
set_requestfile_path("${TOP}/as","/req")

system("install -m 777 -d ${TOP}/as/save")
system("install -m 777 -d ${TOP}/as/req")

set_pass0_restoreFile("info_positions.sav")
set_pass0_restoreFile("info_settings.sav")
set_pass1_restoreFile("info_settings.sav")

dbLoadRecords("$(EPICS_BASE)/db/save_restoreStatus.db","P=$(IOC_PREFIX)")
dbLoadRecords("$(EPICS_BASE)/db/iocAdminSoft.db","IOC=$(IOC_PREFIX)")
save_restoreSet_status_prefix("$(IOC_PREFIX)")
#asSetFilename("/cf-update/acf/default.acf")
#asSetFilename("/cf-update/acf/null.acf")

iocInit()

# caPutLogInit("ioclog.cs.nsls2.local:7004", 1)

## more autosave/restore machinery
cd ${TOP}/as/req
makeAutosaveFiles()
create_monitor_set("info_positions.req", 5 , "")
create_monitor_set("info_settings.req", 15 , "")

# New Target Monitor
#dbpf("XF:10IDD-OP{Spec:1-Ax:2Thc}Mtr.NTM","0")

cd ${TOP}
dbl > ./records.dbl
#system "cp ./records.dbl /cf-update/$HOSTNAME.$IOCNAME.dbl"

