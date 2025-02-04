within TransiEnt.Consumer.Systems.HouseholdEnergyConverter.Systems;
model Generic_complex
  "Generic System contains PVs, Battery, Hetapump and/or BEV with ComplexPowerPorts"

//________________________________________________________________________________//
// Component of the TransiEnt Library, version: 2.0.2                             //
//                                                                                //
// Licensed by Hamburg University of Technology under the 3-BSD-clause.           //
// Copyright 2021, Hamburg University of Technology.                              //
//________________________________________________________________________________//
//                                                                                //
// TransiEnt.EE, ResiliEntEE, IntegraNet and IntegraNet II are research projects  //
// supported by the German Federal Ministry of Economics and Energy               //
// (FKZ 03ET4003, 03ET4048, 0324027 and 03EI1008).                                //
// The TransiEnt Library research team consists of the following project partners://
// Institute of Engineering Thermodynamics (Hamburg University of Technology),    //
// Institute of Energy Systems (Hamburg University of Technology),                //
// Institute of Electrical Power and Energy Technology                            //
// (Hamburg University of Technology)                                             //
// Fraunhofer Institute for Environmental, Safety, and Energy Technology UMSICHT, //
// Gas- und Wärme-Institut Essen                                                  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//

  // _____________________________________________
  //
  //          Imports and Class Hierarchy
  // _____________________________________________

  extends
    TransiEnt.Consumer.Systems.HouseholdEnergyConverter.Systems.Base.Systems(
    final DHN=false,
    final el_grid=true,
    final gas_grid=false,
    final powerlimitations=true,
    redeclare TransiEnt.Basics.Interfaces.Electrical.ComplexPowerPort epp);

  outer TransiEnt.SimCenter simCenter;
  outer TransiEnt.ModelStatistics modelStatistics;

  // _____________________________________________
  //
  //          Parameters
  // _____________________________________________

  parameter Boolean hotwater=true "Does the heat pump provide energy for the hot water? (if false: water is heated electrically)" annotation (
    HideResult=true,
    Dialog(group="System setup"),
    choices(checkBox=true));
  parameter Modelica.Units.SI.Power P_flowheater=18e3 "Nominal electric power of the flow heater" annotation (HideResult=true, Dialog(group="System setup"), enable=(not hotwater));
  parameter Boolean heating=true "Does the heat pump provide energy for the space heating? (if false: space heating not accounted for)" annotation (
    HideResult=true,
    Dialog(group="System setup"),
    choices(checkBox=true));
  parameter Boolean battery=false "Is there a PV battery installed?" annotation (
    Dialog(group="System setup"),
    choices(checkBox=true),
    HideResult=true);
  parameter Boolean bev=true "Is there an electrical vehicle?" annotation (
    Dialog(group="System setup"),
    choices(checkBox=true),
    HideResult=true);



  parameter Modelica.Units.SI.TemperatureDifference Delta_T_internal=5 "Temperature difference between refrigerant and source/sink temperature" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.HeatFlowRate Q_flow_n=10.5e3 "Nominal heat flow of heat pump at nominal conditions according to EN14511" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Real COP_n=3.7 "Coefficient of performance at nominal conditions according to EN14511" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.HeatFlowRate P_el_max=5.0e3 "Maximal electric Power of heat pump at 7°C/55°C" annotation (Dialog(group="Heatpump"));
  parameter Real COP_max=6.5 "Maximal coefficient of performance at high source temperatures" annotation (Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.TemperatureDifference Delta_T_elHeater=2 "Lack of storage temperature to switch on electric heater" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.Power P_el_Heater=4.5e3 "Nominal electric power of the backup heater" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.Efficiency eta_Heater=0.95 "Efficiency of the backup heater" annotation (HideResult=true, Dialog(group="Heatpump"));
  //parameter Modelica.Units.SI.Temperature T_set=55 + 273.25 "Heatpump supply temperature" annotation (Dialog(group="Heatpump"));

  //parameter Modelica.Units.SI.Temperature T_s_max=343.15 "Maximum storage temperature" annotation (HideResult=true, Dialog(group="Storage"));
  //parameter Modelica.Units.SI.Temperature T_s_min=323.15 "Minimum storage temperature" annotation (HideResult=true, Dialog(group="Storage"));
  //parameter Modelica.Units.SI.Temperature T_start=60 + 273.15 "Start value of the storage temperature" annotation (HideResult=true, Dialog(group="Storage"));
  parameter Modelica.Units.SI.Temperature T_set_buffer=45 + 273.25 "Buffer set temperature" annotation (Dialog(group="Buffer"));
  parameter Modelica.Units.SI.Volume V_buffer=0.5 "Volume of the Storage" annotation (Dialog(group="Buffer"));
  parameter Modelica.Units.SI.Height height_buffer=1.3 "Height of heat storage" annotation (Dialog(group="Buffer"));
  parameter Modelica.Units.SI.Diameter d_buffer=sqrt(V_buffer/height_buffer*4/Modelica.Constants.pi) "Diameter of heat storage" annotation (HideResult=true, Dialog(group="Buffer"));
  parameter Modelica.Units.SI.Temperature T_set_hotwater=55 + 273.25 "Hot Water set temperature" annotation (Dialog(group="Hot Water Storage"));
  parameter Modelica.Units.SI.Volume V_hotwater=0.2 "Volume of the Storage" annotation (Dialog(group="Hot Water Storage"));
  parameter Modelica.Units.SI.Height height_hotwater=0.8 "Height of heat storage" annotation (Dialog(group="Hot Water Storage"));
  parameter Modelica.Units.SI.Diameter d_hotwater=sqrt(V_hotwater/height_hotwater*4/Modelica.Constants.pi) "Diameter of heat storage" annotation (HideResult=true, Dialog(group="Hot Water Storage"));
  //parameter Modelica.Units.NonSI.Temperature_degC T_amb=15 "Assumed constant ambient temperature" annotation (HideResult=true, Dialog(group="Hot Water Storage"));
  //parameter Modelica.Units.SI.SurfaceCoefficientOfHeatTransfer k=0.08 "Coefficient of heat transfer through tank surface" annotation (HideResult=true, Dialog(group="Hot Water Storage"));

  parameter Real summer_start=136 "Day of the year for the start of summer operation" annotation (Dialog(group="Control parameters"));
  parameter Real winter_start=245 "Day of the year for the end of summer operation" annotation (Dialog(group="Control parameters"));


  parameter Modelica.Units.SI.Power P_inst_PV1=5000 "Installed power of system 1" annotation (HideResult=true, Dialog(group="PV System 1"));
  parameter Modelica.Units.SI.Power Pmpp_PV1=200 "Peak power of one module" annotation (HideResult=true, Dialog(group="PV System 1"));
  parameter Modelica.Units.SI.Area Area_PV1=1.18 "Area of one complete module" annotation (HideResult=true, Dialog(group="PV System 1"));
  parameter Real Strings_PV1=1 "Choose amount of strings" annotation (HideResult=true, Dialog(group="PV System 1"));
  parameter TransiEnt.Producer.Electrical.Photovoltaics.Advanced_PV.Characteristics.Generic_Characteristics_PVModule PVModuleCharacteristics_PV1=TransiEnt.Producer.Electrical.Photovoltaics.Advanced_PV.Characteristics.PVModule_Characteristics_Sanyo_HIT_200_BA3() "Characteristics of PV Module" annotation (
    HideResult=true,
    choicesAllMatching,
    Dialog(group="PV System 1"));
  parameter Modelica.Units.SI.Angle Tilt_PV1=Modelica.Units.Conversions.from_deg(30) "Inclination of surface" annotation (HideResult=true, Dialog(group="PV System 1"));
  parameter Modelica.Units.SI.Angle Azimuth_PV1=0 "Gyration of surface; Orientation: +90=West, -90=East, 0=South" annotation (HideResult=true, Dialog(group="PV System 1"));

  parameter Modelica.Units.SI.Power P_inst_PV2=0 "Installed power of system 2" annotation (HideResult=true, Dialog(group="PV System 2"));
  parameter Modelica.Units.SI.Power Pmpp_PV2=200 "Peak power of one module" annotation (HideResult=true, Dialog(group="PV System 2"));
  parameter Modelica.Units.SI.Area Area_PV2=1.18 "Area of one complete module" annotation (HideResult=true, Dialog(group="PV System 2"));
  parameter Real Strings_PV2=1 "Choose amount of strings" annotation (HideResult=true, Dialog(group="PV System 2"));
  parameter TransiEnt.Producer.Electrical.Photovoltaics.Advanced_PV.Characteristics.Generic_Characteristics_PVModule PVModuleCharacteristics_PV2=TransiEnt.Producer.Electrical.Photovoltaics.Advanced_PV.Characteristics.PVModule_Characteristics_Sanyo_HIT_200_BA3() "Characteristics of PV Module" annotation (
    HideResult=true,
    choicesAllMatching,
    Dialog(group="PV System 2"));
  parameter Modelica.Units.SI.Angle Tilt_PV2=Modelica.Units.Conversions.from_deg(30) "Inclination of surface" annotation (HideResult=true, Dialog(group="PV System 2"));
  parameter Modelica.Units.SI.Angle Azimuth_PV2=Modelica.Units.Conversions.from_deg(180) "Gyration of surface; Orientation: +90=West, -90=East, 0=South" annotation (HideResult=true, Dialog(group="PV System 2"));

  parameter Real GroundCoverageRatio=0.0 "ratio of covered ground of modules to area of modules" annotation (HideResult=true, Dialog(group="PV Parameters"));
  parameter Real LossesDC=4.44 "losses in % through connections, wiring, tracking error and mismatches" annotation (HideResult=true, Dialog(group="PV Parameters"));
  parameter Real Soiling=5 "Average annual losses of radiation in % due to soiling" annotation (HideResult=true, Dialog(group="PV Parameters"));
  parameter Real Albedo=0.25 "Refelectance of the ground" annotation (HideResult=true, Dialog(group="PV Parameters"));

  parameter Modelica.Units.SI.Angle longitude_local=Modelica.Units.Conversions.from_deg(11.55) "Longitude of the local position, east positive, 10 East for Hamburg" annotation (Dialog(group="Radiation Parameters"));
  parameter Modelica.Units.SI.Angle longitude_standard=Modelica.Units.Conversions.from_deg(15) "Needed for calculation of coordinated universal time (utc), 15 for central european time, 30 for central european summer time" annotation (Dialog(group="Radiation Parameters"));
  parameter Modelica.Units.NonSI.Time_day totaldays=365 "Total days of the year, standard=365, leap year=366" annotation (Dialog(group="Radiation Parameters"));
  parameter Modelica.Units.SI.Angle latitude=Modelica.Units.Conversions.from_deg(48.17) "Latitude of the local position, north posiive, 53,55 North for Hamburg" annotation (Dialog(group="Radiation Parameters"));


  parameter Modelica.Units.SI.ActivePower P_n=5000 "Rated power of the inverter" annotation (Dialog(group="PV Parameters"));
  parameter Modelica.Units.SI.PowerFactor cosphi=1 "Operating power factor of the inverter" annotation (Dialog(group="PV Parameters"));
  parameter Real Threshold=0.7 "Percentage of peak power at which power is cut" annotation (Dialog(group="PV Parameters"));
  parameter Integer behavior=-1 annotation (
    Evaluate=true,
    HideResult=true,
    choices(
      __Dymola_radioButtons=true,
      choice=1 "inductive",
      choice=-1 "capacitive"),
    Dialog(group="PV Parameters"));
  parameter Modelica.Units.SI.Efficiency eta_Inverter=0.97 "Efficiency of the inverter" annotation (Dialog(group="PV Parameters"));

  parameter TransiEnt.Storage.Electrical.Specifications.LithiumIon params(
    P_max_load=3000,
    P_max_unload=3000,
    E_max=3000*3*3600) "Record of generic storage parameters" annotation (
    Dialog(group="Battery Parameters"),
    choicesAllMatching,
    HideResult=true);

  parameter Real vehicleEfficiency=18  "[kWh/100km] Average electricity use per kilometer"    annotation (Dialog(group=
          "Electric Vehicle"));
  parameter Modelica.Units.SI.Power P_max_BEV_drive(displayUnit="kW")=200000 "Maximum driving power" annotation (Dialog(group="Electric Vehicle"));
  parameter Modelica.Units.SI.Power P_max_BEV_charge(displayUnit="kW")=22000 "Maximum charging power" annotation (Dialog(group="Electric Vehicle"));
  parameter Modelica.Units.SI.Energy C_Bat(displayUnit="kWh")=252000000 "Battery capacity" annotation (Dialog(group="Electric Vehicle"));
  //parameter Real SOCStart=0.7 "Battery state of charge at the start of the simulation" annotation (Dialog(group="Electric Vehicle"));
  parameter String relativepath="emobility/Distance+LocationProfiles_family_15min.txt" "relativpath to vehicle and location data" annotation (Dialog(group="Electric Vehicle"));
  parameter Integer column=1 "Table column set for vehicle and location data" annotation (Dialog(group="Electric Vehicle"));
  parameter Modelica.Units.SI.Power P_chargingStation(displayUnit="kW") = 11000 "Charging power of the home charging station" annotation (Dialog(group="Charging station"));
  parameter Modelica.Units.SI.Power P_work(displayUnit="kW")=0 "Charging power of the charging station at work" annotation (Dialog(group="Charging station", enable=inputDataType == "Distance"));
  parameter Modelica.Units.SI.Power P_public(displayUnit="kW")=0 "Charging power of public charging stations" annotation (Dialog(group="Charging station", enable=inputDataType == "Distance"));
  parameter Modelica.Units.SI.Power P_fast(displayUnit="kW")=0 "Charging power of fast charging" annotation (Dialog(group="Charging station", enable=inputDataType == "Distance"));
  parameter Modelica.Units.SI.Power P_superfast(displayUnit="kW")=0 "Charging power of superfast charging" annotation (Dialog(group="Charging station", enable=inputDataType == "Distance"));

  parameter Modelica.Units.SI.Power MinPower=4200 "Minimal Power per device during grid curtailment" annotation (HideResult=true, Dialog(group="Other"));

  // _____________________________________________
  //
  //                   Variables
  // _____________________________________________

  Modelica.Units.SI.Power P "Consumed or produced electric power";
  Modelica.Units.SI.Temperature T_source=simCenter.ambientConditions.temperature.value + 273.15 "Temperature of heat source" annotation (Dialog(group="Heatpump"));

  // _____________________________________________
  //
  //           Instances of other Classes
  // _____________________________________________

  TransiEnt.Storage.Heat.HotWaterStorage_constProp_L2.HotWaterStorage_constProp_L2
    buffer(
    useFluidPorts=false,
    T_s_max=T_set_buffer + 10,
    T_s_min=T_set_buffer - 10,
    d=d_buffer,
    height=height_buffer,
    T_start=T_set_buffer) if
                       heating
    annotation (Placement(transformation(extent={{70,62},{90,82}})));
    //k=k,
    //T_amb=T_amb,

  Producer.Electrical.Photovoltaics.Advanced_PV.SinglePhasePVInverter                                            inverter(
    eta=eta_Inverter,
    cosphi=cosphi,
    behavior=behavior,
    P_n=P_n,
    P_PV=P_inst_PV1+P_inst_PV2,
    Threshold=Threshold,
    redeclare Basics.Interfaces.Electrical.ComplexPowerPort epp_AC)
                   annotation (Placement(transformation(
        extent={{9,-7},{-9,7}},
        rotation=90,
        origin={-103,-31})));

  TransiEnt.Components.Boundaries.Electrical.ComplexPower.PQBoundary     pQBoundary(    useInputConnectorQ=false, useInputConnectorP=true,
    cosphi_boundary=0.9)                                                                                                                   annotation (Placement(transformation(extent={{-42,-68},
            {-26,-52}})));

  Producer.Heat.Power2Heat.ElectricBoiler.ElectricBoiler                    electricHeater(
    change_sign=true,
    usePelset=false,
    Q_flow_n=P_el_Heater*eta_Heater,
    eta=eta_Heater,
    useFluidPorts=false,
    usePowerPort=true,
    redeclare connector PowerPortModel =
        Basics.Interfaces.Electrical.ComplexPowerPort,
    redeclare model PowerBoundaryModel =
        Components.Boundaries.Electrical.ComplexPower.PQBoundary,
    powerBoundary(useInputConnectorQ=false, cosphi_boundary=0.99)) if heating
     or hotwater                                                   annotation (Placement(transformation(extent={{52,-70},
            {66,-56}})));
  Modelica.Blocks.Math.Add add3 if heating or hotwater
                                annotation (Placement(transformation(extent={{-4,-4},
            {4,4}},
        rotation=90,
        origin={66,-32})));

  Producer.Heat.Power2Heat.Heatpump.Heatpump                                                                  heatPump(
    usePowerPort=true,
    COP_max=COP_max,
    useFluidPorts=false,
    useHeatPort=false,
    Delta_T_internal=Delta_T_internal,
    Q_flow_n=Q_flow_n,
    COP_n=COP_n,
    redeclare connector PowerPortModel =
        TransiEnt.Basics.Interfaces.Electrical.ComplexPowerPort,
    redeclare model PowerBoundaryModel =
        TransiEnt.Components.Boundaries.Electrical.ComplexPower.PQBoundary,
    Power(useInputConnectorQ=false, cosphi_boundary=0.99)) if heating or
    hotwater                                               annotation (Placement(transformation(extent={{30,-54},
            {48,-36}})));
  TransiEnt.Consumer.Electrical.BatteryElectricVehicle       batteryElectricVehicle(
    vehicleEfficiency=vehicleEfficiency,
    P_max_BEV_drive=P_max_BEV_drive,
    P_max_BEV_charge=P_max_BEV_charge,
    C_Bat=C_Bat,
    column=column,
    P_chargingStation=P_chargingStation,
    P_fast=P_fast,
    P_superfast=P_superfast,
    useExternalControl=true,
    controlType="Power limit",
    redeclare model DistanceLocationTable =
        Basics.Tables.ElectricGrid.Electromobility.DistanceLocationProfiles_family_15min
        (relativepath=relativepath),
    redeclare model PowerBoundaryModel =
        TransiEnt.Components.Boundaries.Electrical.ComplexPower.PQBoundary,
    Power(cosphi_boundary=0.95),
    redeclare connector PowerPortModel =
        Basics.Interfaces.Electrical.ComplexPowerPort) if bev                                                annotation (Placement(transformation(extent={{-10,-10},
            {10,10}},
        rotation=270,
        origin={-62,-58})));
  Producer.Electrical.Photovoltaics.Advanced_PV.DNIDHI_Input.PVModule pVModule2(
    P_inst=P_inst_PV1,
    Pmpp=Pmpp_PV1,
    Area=Area_PV1,
    Strings=Strings_PV1,
    GroundCoverageRatio=GroundCoverageRatio,
    LossesDC=LossesDC,
    Soiling=Soiling,
    longitude_local=longitude_local,
    longitude_standard=longitude_standard,
    totaldays=totaldays,
    latitude=latitude,
    slope=Tilt_PV1,
    surfaceAzimuthAngle=Azimuth_PV1,
    reflectance_ground=Albedo)
    annotation (Placement(transformation(extent={{-60,42},{-80,62}})));
  Modelica.Blocks.Sources.RealExpression ambientTemperature(y=simCenter.ambientConditions.temperature.value) annotation (Placement(transformation(
        extent={{10,-6},{-10,6}},
        rotation=0,
        origin={-20,90})));
  Modelica.Blocks.Sources.RealExpression directSolarRadiation(y=simCenter.ambientConditions.directSolarRadiation.value) annotation (Placement(transformation(
        extent={{10,-6},{-10,6}},
        rotation=0,
        origin={-20,80})));
  Modelica.Blocks.Sources.RealExpression diffuseSolarRadiation(y=simCenter.ambientConditions.diffuseSolarRadiation.value) annotation (Placement(transformation(
        extent={{10,-6},{-10,6}},
        rotation=0,
        origin={-20,70})));
  Modelica.Blocks.Sources.RealExpression wind(y=simCenter.ambientConditions.wind.value) annotation (Placement(transformation(
        extent={{10,-7},{-10,7}},
        rotation=0,
        origin={-20,61})));
  Producer.Electrical.Photovoltaics.Advanced_PV.DNIDHI_Input.PVModule                        pVModule1(
    P_inst=P_inst_PV2,
    Pmpp=Pmpp_PV2,
    Area=Area_PV2,
    Strings=Strings_PV2,
    GroundCoverageRatio=GroundCoverageRatio,
    LossesDC=LossesDC,
    Soiling=Soiling,
    longitude_local=longitude_local,
    longitude_standard=longitude_standard,
    totaldays=totaldays,
    latitude=latitude,
    slope=Tilt_PV2,
    surfaceAzimuthAngle=Azimuth_PV2,
    reflectance_ground=Albedo)                   annotation (Placement(transformation(extent={{-60,74},
            {-80,94}})));
  Modelica.Blocks.Sources.RealExpression COP_HP(y=heatPump.COP.y) if heating
     or hotwater annotation (Placement(transformation(
        extent={{-9,-9},{9,9}},
        rotation=180,
        origin={7,-71})));
  TransiEnt.Consumer.Heat.Profiles.HeatingCurve heatingCurve(
    T_room_set=295.15,
    T_amb_min=265.15,
    T_supply_max=T_set_buffer) if heating
                         annotation (Placement(transformation(extent={{-46,22},{
            -40,28}})));
  Modelica.Blocks.Sources.RealExpression Tset1(y=0)    annotation (Placement(transformation(extent={{-46,12},
            {-40,20}})));
  Modelica.Blocks.Math.Max max1 if heating
                                annotation (Placement(transformation(extent={{-32,16},
            {-28,20}})));
  Modelica.Blocks.Sources.RealExpression p_PV(y=pVModule2.P_dc + pVModule1.P_dc)
    annotation (Placement(transformation(
        extent={{10,-9},{-10,9}},
        rotation=90,
        origin={-116,87})));
  TransiEnt.Storage.Electrical.LithiumIonBattery
                    Storage(StorageModelParams=params, redeclare model
      CostModel =
        TransiEnt.Components.Statistics.ConfigurationData.StorageCostSpecs.LithiumIonBattery)
    if battery       annotation (Placement(transformation(extent={{-131,-23},{-109,
            -1}})));
  TransiEnt.Storage.Heat.HotWaterStorage_constProp_L2.HotWaterStorage_constProp_L2 hotwatertank(
    useFluidPorts=false,
    T_s_max=353.15,
    T_s_min=T_set_hotwater - 10,
    d=d_hotwater,
    height=height_hotwater,
    T_start=T_set_hotwater) if
                       hotwater
                     annotation (Placement(transformation(extent={{72,34},{92,
            54}})));
    //T_amb=T_amb,
  Modelica.Blocks.Logical.Switch switch1 if heating and hotwater
    annotation (Placement(transformation(extent={{52,66},{62,76}})));
  Modelica.Blocks.Logical.Switch switch2 if heating and hotwater
    annotation (Placement(transformation(extent={{52,36},{62,46}})));
  Modelica.Blocks.Sources.RealExpression zero1(y=0)
    annotation (Placement(transformation(extent={{28,62},{42,76}})));
  Modelica.Blocks.Logical.Switch T_Storage if
                                            heating and hotwater annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={10,-14})));
  Modelica.Blocks.Logical.Hysteresis hysteresis(
    uLow=T_set_hotwater - 1,
    uHigh=T_set_hotwater + 1,
    pre_y_start=false) if
                         heating and hotwater
                      annotation (Placement(transformation(
        extent={{-4,-4},{4,4}},
        rotation=180,
        origin={56,26})));
  Modelica.Blocks.Logical.Not not1 if heating and hotwater
                                   annotation (Placement(transformation(
        extent={{-4,-4},{4,4}},
        rotation=180,
        origin={44,26})));
  Producer.Heat.Power2Heat.Heatpump.Controller.Control_Heat_HotWater
    control_Heat_HotWater(
    CalculatePHeater=true,
    Modulating=true,
    Q_flow_n=Q_flow_n,
    Delta_T_db=Delta_T_elHeater,
    P_elHeater=P_el_Heater,
    k=1,
    T_i(displayUnit="min") = 1800,
    COP_n=COP_n,
    P_el_max=P_el_max) if      hotwater or heating
    annotation (Placement(transformation(extent={{-4,-66},{16,-42}})));
  Modelica.Blocks.Logical.Switch T_Set if   heating and hotwater annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={26,-14})));
  Modelica.Blocks.Sources.RealExpression Tset_hotwater(y=T_set_hotwater + 1)
    annotation (Placement(transformation(
        extent={{-7,-5},{7,5}},
        rotation=0,
        origin={-27,3})));
  Components.Sensors.ElectricPowerComplex electricPowerComplex(change_of_sign=true)
                                                               annotation (
      Placement(transformation(
        extent={{-4.5,-4.5},{4.5,4.5}},
        rotation=0,
        origin={-73.5,-78.5})));
  Basics.Blocks.Sources.PowerExpression
                               MinimalPower(y=MinPower)
    "Minimal Power per device during grid curtailment "
               annotation (Placement(transformation(
        extent={{-7,-6},{7,6}},
        rotation=0,
        origin={-129,-72})));
  Control_Battery.MaxSelfConsumption maxSelfConsumption if battery annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-120,26})));
  Modelica.Blocks.Sources.RealExpression BatteryCOP(y=Storage.SOC.y) if battery
    annotation (Placement(transformation(
        extent={{-7,-7},{7,7}},
        rotation=180,
        origin={-131,5})));
  Basics.Blocks.Hysteresis_inputVariable           hysteresis_heater if heating
     and hotwater                                                    annotation (Placement(transformation(extent={{26,32},
            {36,42}})));
  Modelica.Blocks.Logical.Or or1 if heating and hotwater annotation (Placement(
        transformation(
        extent={{-4,-4},{4,4}},
        rotation=180,
        origin={32,26})));
  Modelica.Blocks.Math.Add add if heating and hotwater
    annotation (Placement(transformation(extent={{6,38},{14,46}})));
  Modelica.Blocks.Sources.RealExpression uLow3(y=3) if heating and hotwater
                                                              annotation (Placement(transformation(extent={{-6,40},
            {2,48}})));
  Modelica.Blocks.Math.Max max2 annotation (Placement(transformation(extent={{-114,
            -62},{-106,-54}})));
  Producer.Heat.Power2Heat.ElectricBoiler.ElectricBoilerSystem
                                                     flowHeater(P_flowheater=
        P_flowheater) if not hotwater
    annotation (Placement(transformation(extent={{82,-72},{92,-62}})));
  Components.Sensors.ElectricPowerComplex electricPowerComplex1(change_of_sign=
        true)                                                  annotation (
      Placement(transformation(
        extent={{-4.5,-4.5},{4.5,4.5}},
        rotation=0,
        origin={-53.5,-82.5})));
  Modelica.Blocks.Logical.Switch switch5 if heating
    annotation (Placement(transformation(extent={{-2,-2},{2,2}},
        rotation=0,
        origin={-12,24})));
  Modelica.Blocks.Sources.RealExpression T_min(y=heatingCurve.T_room_set) if
    heating                                               annotation (Placement(
        transformation(
        extent={{-2,-3},{2,3}},
        rotation=180,
        origin={-12,31})));
  Basics.Blocks.SwitchAtSeason  summerWinterSwitch(summer_start=summer_start,
      winter_start=winter_start) if heating                                                              annotation (Placement(transformation(extent={{-34,24},
            {-28,30}})));
equation

  // _____________________________________________
  //
  //            Characteristic equations
  // _____________________________________________

  P = epp.P;

  // _____________________________________________
  //
  //            Connect statements
  // _____________________________________________


  if not hotwater then
    connect(switch5.y, control_Heat_HotWater.T_set) annotation (Line(points={{-9.8,24},
            {22,24},{22,-2},{18,-2},{18,-28},{-10,-28},{-10,-53.4},{-3.2,-53.4}},
                                                                 color={0,0,127}));
    connect(add3.y, buffer.Q_flow_store) annotation (Line(points={{66,-27.6},{
            66,72},{70.6,72}},                              color={0,0,127}));
    connect(buffer.T_stor_out, control_Heat_HotWater.T) annotation (Line(points={{78.2,
            81.6},{24,81.6},{24,54},{-8,54},{-8,-48},{-3.4,-48}},
                 color={0,0,127}));
  end if;

  if not heating then
    connect(Tset_hotwater.y, control_Heat_HotWater.T_set) annotation (Line(points={{-19.3,3},
            {-10,3},{-10,-53.4},{-3.2,-53.4}},
        color={0,0,127}));
    connect(add3.y, hotwatertank.Q_flow_store) annotation (Line(points={{66,
            -27.6},{66,44},{72.6,44}},                          color={0,0,127}));
    connect(hotwatertank.T_stor_out, control_Heat_HotWater.T) annotation (Line(
        points={{80.2,53.6},{80.2,50},{80,50},{80,54},{-8,54},{-8,-48},{-3.4,
            -48}},
        color={0,0,127}));
  end if;


      connect(pQBoundary.P_el_set, demand.electricPowerDemand) annotation (Line(
        points={{-38.8,-50.4},{-38.8,-38},{-48,-38},{-48,42},{-28,42},{-28,56},
          {4.68,56},{4.68,100.48}},
                                  color={0,127,127}), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(electricHeater.Q_flow_gen, add3.u2) annotation (Line(
      points={{66.42,-57.26},{66.42,-58},{68.4,-58},{68.4,-36.8}},
      color={175,0,0},
      pattern=LinePattern.Dash));
  connect(heatPump.Heat_output, add3.u1) annotation (Line(
      points={{49.44,-39.78},{49.44,-36.8},{63.6,-36.8}},
      color={175,0,0},
      pattern=LinePattern.Dash));
  connect(pVModule2.epp, inverter.epp_DC) annotation (Line(
      points={{-79.3,51.4},{-103,51.4},{-103,-22.18}},
      color={0,135,135},
      thickness=0.5));
  connect(wind.y, pVModule2.WindSpeed_in) annotation (Line(points={{-31,61},{-32,
          61},{-32,60},{-34,60},{-34,44},{-58,44}}, color={0,0,127}));
  connect(pVModule2.DHI_in, diffuseSolarRadiation.y) annotation (Line(points={{-58,
          49.4},{-36,49.4},{-36,70},{-31,70}},     color={0,0,127}));
  connect(pVModule2.DNI_in, directSolarRadiation.y) annotation (Line(points={{-58,
          54.4},{-40,54.4},{-40,80},{-31,80}}, color={0,0,127}));
  connect(pVModule2.T_in, ambientTemperature.y) annotation (Line(points={{-58,60},
          {-42,60},{-42,90},{-31,90}},     color={0,0,127}));
  connect(pVModule1.T_in, ambientTemperature.y) annotation (Line(points={{-58,92},
          {-42,92},{-42,90},{-31,90}},                                                                         color={0,0,127}));
  connect(pVModule1.DNI_in, directSolarRadiation.y) annotation (Line(points={{-58,
          86.4},{-44,86.4},{-44,80},{-31,80}},                                                                         color={0,0,127}));
  connect(pVModule1.DHI_in, diffuseSolarRadiation.y) annotation (Line(points={{-58,
          81.4},{-46,81.4},{-46,70},{-31,70}},                                                                          color={0,0,127}));
  connect(pVModule1.WindSpeed_in, pVModule2.WindSpeed_in) annotation (Line(
        points={{-58,76},{-48,76},{-48,68},{-34,68},{-34,44},{-58,44}}, color={
          0,0,127}));
  connect(Tset1.y, max1.u2) annotation (Line(points={{-39.7,16},{-32.4,16},{-32.4,
          16.8}},                                                                                    color={0,0,127}));
  connect(heatingCurve.T_supply, max1.u1) annotation (Line(points={{-39.88,25.6},
          {-36,25.6},{-36,19.2},{-32.4,19.2}},                                               color={0,0,127}));
  connect(Storage.epp, inverter.epp_DC) annotation (Line(
      points={{-109,-12},{-103,-12},{-103,-22.18}},
      color={0,135,135},
      thickness=0.5));
  connect(epp, epp) annotation (Line(
      points={{-80,-98},{-80,-98}},
      color={28,108,200},
      thickness=0.5));
  connect(pVModule1.epp, inverter.epp_DC) annotation (Line(
      points={{-79.3,83.4},{-92,83.4},{-92,82},{-103,82},{-103,-22.18}},
      color={0,135,135},
      thickness=0.5));
  connect(buffer.Q_flow_demand, demand.heatingPowerDemand) annotation (Line(
      points={{90,72},{96,72},{96,86},{0,86},{0,100.48}},
      color={175,0,0},
      pattern=LinePattern.Dash), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(hotwatertank.Q_flow_demand, demand.hotWaterPowerDemand) annotation (
      Line(
      points={{92,44},{98,44},{98,84},{-4.8,84},{-4.8,100.48}},
      color={175,0,0},
      pattern=LinePattern.Dash), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(switch1.y, buffer.Q_flow_store) annotation (Line(points={{62.5,71},{
          66,71},{66,72},{70.6,72}}, color={0,0,127}));
  connect(switch2.y, hotwatertank.Q_flow_store)
    annotation (Line(points={{62.5,41},{66,41},{66,44},{72.6,44}},
                                                            color={0,0,127}));
  connect(switch1.u3, add3.y) annotation (Line(points={{51,67},{50,67},{50,64},
          {66,64},{66,-27.6}}, color={0,0,127}));
  connect(zero1.y, switch1.u1)
    annotation (Line(points={{42.7,69},{46,69},{46,75},{51,75}},
                                                 color={0,0,127}));
  connect(switch2.u3, switch1.u1)
    annotation (Line(points={{51,37},{46,37},{46,75},{51,75}},
                                                             color={0,0,127}));
  connect(hotwatertank.T_stor_out, T_Storage.u1) annotation (Line(points={{80.2,
          53.6},{64,53.6},{64,18},{14.8,18},{14.8,-6.8}}, color={0,0,127}));
  connect(buffer.T_stor_out, T_Storage.u3) annotation (Line(points={{78.2,81.6},
          {24,81.6},{24,54},{-8,54},{-8,-6.8},{5.2,-6.8}}, color={0,0,127}));
  connect(switch2.u1, add3.y) annotation (Line(points={{51,45},{51,50},{66,50},
          {66,-27.6}},         color={0,0,127}));
  connect(not1.u, hysteresis.y)
    annotation (Line(points={{48.8,26},{51.6,26}},   color={255,0,255}));
  connect(control_Heat_HotWater.Q_flow_set_HP, heatPump.Q_flow_set) annotation (
     Line(
      points={{16.5,-52.1},{22,-52.1},{22,-50},{29.46,-50},{29.46,-49.86}},
      color={175,0,0},
      pattern=LinePattern.Dash));
  connect(control_Heat_HotWater.P_set_electricHeater, electricHeater.Q_flow_set)
    annotation (Line(
      points={{16.5,-59.7},{20,-59.7},{20,-62.3},{51.72,-62.3}},
      color={0,135,135},
      pattern=LinePattern.Dash));
  connect(COP_HP.y, control_Heat_HotWater.COP) annotation (Line(points={{-2.9,-71},
          {-16,-71},{-16,-57},{-4.2,-57}}, color={0,0,127}));
  connect(T_Storage.u2, T_Set.u2) annotation (Line(points={{10,-6.8},{10,0},{26,
          0},{26,-6.8}}, color={255,0,255}));
  connect(Tset_hotwater.y, T_Set.u1) annotation (Line(points={{-19.3,3},{36,3},{
          36,-6.8},{30.8,-6.8}},  color={0,0,127}));
  connect(electricPowerComplex.epp_IN, epp) annotation (Line(
      points={{-77.64,-78.5},{-80,-78.5},{-80,-98}},
      color={28,108,200},
      thickness=0.5));
  connect(inverter.epp_AC, epp) annotation (Line(
      points={{-103,-40},{-103,-82},{-80,-82},{-80,-98}},
      color={28,108,200},
      thickness=0.5));

  connect(batteryElectricVehicle.epp, electricPowerComplex.epp_OUT) annotation (
     Line(
      points={{-62.2,-67.8},{-62.2,-74},{-69.27,-74},{-69.27,-78.5}},
      color={28,108,200},
      thickness=0.5));

  connect(T_Storage.y, control_Heat_HotWater.T) annotation (Line(points={{10,
          -20.6},{10,-32},{-8,-32},{-8,-48},{-3.4,-48}}, color={0,0,127}));
  connect(T_Set.y, control_Heat_HotWater.T_set) annotation (Line(points={{26,
          -20.6},{26,-28},{-10,-28},{-10,-53.4},{-3.2,-53.4}}, color={0,0,127}));

  connect(maxSelfConsumption.P_PV, p_PV.y) annotation (Line(points={{-114,35.4},
          {-114,44},{-116,44},{-116,76}}, color={0,0,127}));
  connect(maxSelfConsumption.P_Consumer, electricPowerComplex.P) annotation (
      Line(points={{-126,35.2},{-126,38},{-96,38},{-96,-74},{-78,-74},{-78,
          -74.63},{-75.75,-74.63}},      color={0,0,127}));
  connect(BatteryCOP.y, maxSelfConsumption.SOC) annotation (Line(points={{-138.7,
          5},{-140,5},{-140,26},{-129.4,26}},   color={0,0,127}));
  connect(control_Heat_HotWater.T_set, heatPump.T_set) annotation (Line(points={{-3.2,
          -53.4},{-10,-53.4},{-10,-38},{16,-38},{16,-39.6},{29.46,-39.6}},
        color={0,0,127}));
  connect(or1.y, T_Storage.u2) annotation (Line(points={{27.6,26},{18,26},{18,0},
          {10,0},{10,-6.8}}, color={255,0,255}));
  connect(not1.y, or1.u1) annotation (Line(points={{39.6,26},{36.8,26}},
                                                  color={255,0,255}));
  connect(hysteresis_heater.u, buffer.T_stor_out) annotation (Line(points={{25.5,37},
          {24,37},{24,81.6},{78.2,81.6}},     color={0,0,127}));
  connect(add.y, hysteresis_heater.uHigh) annotation (Line(points={{14.4,42},{
          22,42},{22,41},{25.7,41}},   color={0,0,127}));
  connect(uLow3.y, add.u1) annotation (Line(points={{2.4,44},{2,44},{2,44.4},{
          5.2,44.4}},
        color={0,0,127}));
  connect(hysteresis_heater.y, or1.u2) annotation (Line(points={{36.5,37},{36.8,
          29.2}},                                       color={255,0,255}));
  connect(maxSelfConsumption.P_set_battery, Storage.P_set)
    annotation (Line(points={{-120,16},{-120,-1.66}}, color={0,0,127}));
  connect(MinimalPower.y, max2.u2) annotation (Line(
      points={{-121.3,-72},{-120,-72},{-120,-60.4},{-114.8,-60.4}},
      color={0,135,135},
      pattern=LinePattern.Dash));
  connect(max2.y, control_Heat_HotWater.P_SVE) annotation (Line(points={{-105.6,
          -58},{-86,-58},{-86,-42},{-16,-42},{-16,-44.2},{-4.2,-44.2}}, color={0,
          0,127}));
  connect(P_limit, max2.u1) annotation (Line(points={{-144,-54},{-144,-55.6},{
          -114.8,-55.6}}, color={0,0,127}));
  connect(or1.y, switch2.u2) annotation (Line(points={{27.6,26},{18,26},{18,46},
          {48,46},{48,41},{51,41}}, color={255,0,255}));
  connect(or1.y, switch1.u2) annotation (Line(points={{27.6,26},{18,26},{18,46},
          {48,46},{48,71},{51,71}}, color={255,0,255}));
  connect(add.u2, hysteresis_heater.uLow) annotation (Line(points={{5.2,39.6},{5.2,
          40},{4,40},{4,34},{6,34},{6,33},{25.5,33}},
                                              color={0,0,127}));
  connect(hotwatertank.T_stor_out, hysteresis.u) annotation (Line(points={{80.2,
          53.6},{64,53.6},{64,26},{60.8,26}}, color={0,0,127}));
  connect(flowHeater.Q_flow_demand, demand.hotWaterPowerDemand) annotation (
      Line(
      points={{92.2,-66},{98,-66},{98,84},{-4.8,84},{-4.8,100.48}},
      color={175,0,0},
      pattern=LinePattern.Dash), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(electricPowerComplex.epp_OUT, electricPowerComplex1.epp_IN)
    annotation (Line(
      points={{-69.27,-78.5},{-62,-78.5},{-62,-82.5},{-57.64,-82.5}},
      color={28,108,200},
      thickness=0.5));
  connect(electricPowerComplex1.epp_OUT, heatPump.epp) annotation (Line(
      points={{-49.27,-82.5},{44,-82.5},{44,-58},{45.84,-58},{45.84,-54}},
      color={28,108,200},
      thickness=0.5));
  connect(electricHeater.epp, electricPowerComplex1.epp_OUT) annotation (Line(
      points={{59,-70.14},{58,-70.14},{58,-82.5},{-49.27,-82.5}},
      color={28,108,200},
      thickness=0.5));
  connect(electricPowerComplex1.epp_OUT, flowHeater.epp) annotation (Line(
      points={{-49.27,-82.5},{58,-82.5},{58,-76},{87,-76},{87,-72.1}},
      color={28,108,200},
      thickness=0.5));
  connect(pQBoundary.epp, electricPowerComplex1.epp_OUT) annotation (Line(
      points={{-42,-60},{-48,-60},{-48,-74},{-44,-74},{-44,-82.5},{-49.27,-82.5}},
      color={28,108,200},
      thickness=0.5));

  connect(batteryElectricVehicle.P_limit, max2.y) annotation (Line(points={{
          -62.5,-47.1},{-62.5,-42},{-86,-42},{-86,-58},{-105.6,-58}}, color={0,
          127,127}));
  connect(summerWinterSwitch.summer_operation,switch5. u2) annotation (Line(
        points={{-27.82,27},{-18,27},{-18,24},{-14.4,24}},
                                                   color={255,0,255}));
  connect(T_min.y,switch5. u1) annotation (Line(points={{-14.2,31},{-16,31},{-16,
          25.6},{-14.4,25.6}},
                       color={0,0,127}));
  connect(switch5.y, hysteresis_heater.uLow) annotation (Line(points={{-9.8,24},
          {6,24},{6,33},{25.5,33}}, color={0,0,127}));
  connect(switch5.y, T_Set.u3) annotation (Line(points={{-9.8,24},{22,24},{22,-6.8},
          {21.2,-6.8}},                                           color={0,0,127}));
  connect(switch5.u3, max1.y) annotation (Line(points={{-14.4,22.4},{-26,22.4},{
          -26,18},{-27.8,18}}, color={0,0,127}));
  annotation (
    HideResult=true,
    Dialog(tab="Tracking and Mounting"),
    choices(choice="Yes", choice="No"),
    Icon(coordinateSystem(extent={{-140,-100},{100,100}}),
         graphics={
        Ellipse(
          lineColor={0,125,125},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          extent={{-100,102},{100,-98}}),
        Rectangle(
          extent={{12,10},{78,-54}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{28,18},{68,2}},
          lineColor={0,0,0},
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{28,-46},{68,-62}},
          lineColor={0,0,0},
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{68,-14},{88,-34}},
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{6,-12},{18,-12},{12,-22},{18,-32},{6,-32},{12,-22},{6,-12}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{72,-32},{78,-14},{84,-32}},
          color={0,0,0},
          smooth=Smooth.None),
        Ellipse(
          extent={{-52,56},{-86,24}},
          lineColor={255,128,0},
          fillColor={255,255,0},
          fillPattern=FillPattern.Sphere),
        Polygon(
          points={{-38,48},{8,48},{-28,-22},{-74,-22},{-38,48}},
          smooth=Smooth.None,
          fillColor={0,96,141},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Line(
          points={{-22,48},{-58,-22}},
          smooth=Smooth.None,
          color={255,255,255}),
        Line(
          points={{-12,48},{-48,-22}},
          smooth=Smooth.None,
          color={255,255,255}),
        Line(
          points={{0,52},{-40,-24}},
          smooth=Smooth.None,
          color={255,255,255}),
        Line(
          points={{-50,38},{10,38}},
          color={255,255,255},
          smooth=Smooth.None),
        Line(
          points={{-52,28},{-2,28}},
          color={255,255,255},
          smooth=Smooth.None),
        Line(
          points={{-62,8},{-10,8}},
          color={255,255,255},
          smooth=Smooth.None),
        Line(
          points={{-108,-22},{-26,-22}},
          color={255,255,255},
          smooth=Smooth.None),
        Line(
          points={{-68,-2},{-12,-2}},
          color={255,255,255},
          smooth=Smooth.None),
        Line(
          points={{-76,-12},{-20,-12}},
          color={255,255,255},
          smooth=Smooth.None),
        Line(
          points={{-26,58},{-66,-22}},
          smooth=Smooth.None,
          color={255,255,255}),
        Line(
          points={{-56,18},{-6,18}},
          color={255,255,255},
          smooth=Smooth.None)}),
    Documentation(info="<html>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">1. Purpose of model</span></b></p>
<p>Combination of PV, heatpump, electric heater and thermal storage models to be used in the energyConverter.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(Purely technical component without physical modeling.)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">3. Limits of validity </span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(Purely technical component without physical modeling.)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">4. Interfaces</span></b></p>
<p>TransiEnt.Basics.Interfaces.Combined.HouseholdDemandIn <b>demand</b></p>
<p>TransiEnt.Basics.Interfaces.Electrical.ApparentPowerPort <b>epp - connection to electrical grid</b></p><p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">5. Nomenclature</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">6. Governing Equations</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">7. Remarks for Usage</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">The model contains models for a heat pump, an electric heater, a thermal storage tank, a PV module, an inverter and a controller for the operation of the heat pump and the electrical heater. Different control modes can be selected. </span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">8. Validation</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">9. References</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">10. Version History</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model created by Anne Hagemeier, Fraunhofer UMSICHT in 2017</span></p>
</html>"),
    Diagram(coordinateSystem(extent={{-140,-100},{100,100}})));
end Generic_complex;
