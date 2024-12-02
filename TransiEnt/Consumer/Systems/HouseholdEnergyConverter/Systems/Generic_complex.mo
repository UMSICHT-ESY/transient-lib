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
  parameter Boolean heating=true "Does the heat pump provide energy for the space heating? (if false: space heating not accounted for)" annotation (
    HideResult=true,
    Dialog(group="System setup"),
    choices(checkBox=true));
  parameter Boolean battery=false "Is there a PV battery installed?" annotation (
    Dialog(group="System setup"),
    choices(checkBox=true),
    HideResult=true);

  parameter Modelica.Units.SI.TemperatureDifference Delta_T_internal=5 "Temperature difference between refrigerant and source/sink temperature" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.TemperatureDifference Delta_T_db=2 "Deadband of hysteresis control" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.HeatFlowRate Q_flow_n=3.5e3 "Nominal heat flow of heat pump at nominal conditions according to EN14511" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Real COP_n=3.7 "Coefficient of performance at nominal conditions according to EN14511" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.Power P_el_n=4.5e3 "Nominal electric power of the backup heater" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.Efficiency eta_Heater=0.95 "Efficiency of the backup heater" annotation (HideResult=true, Dialog(group="Heatpump"));
  parameter Modelica.Units.SI.Temperature T_set=55 + 273.25 "Heatpump supply temperature" annotation (Dialog(group="Heatpump"));

  parameter Modelica.Units.SI.Temperature T_s_max=343.15 "Maximum storage temperature" annotation (HideResult=true, Dialog(group="Storage"));
  parameter Modelica.Units.SI.Temperature T_s_min=323.15 "Minimum storage temperature" annotation (HideResult=true, Dialog(group="Storage"));
  parameter Modelica.Units.SI.Temperature T_start=60 + 273.15 "Start value of the storage temperature" annotation (HideResult=true, Dialog(group="Storage"));
  parameter Modelica.Units.SI.Volume V_Storage=0.5 "Volume of the Storage" annotation (Dialog(group="Storage"));
  parameter Modelica.Units.SI.Height height=1.3 "Height of heat storage" annotation (Dialog(group="Storage"));
  parameter Modelica.Units.SI.Diameter d=sqrt(V_Storage/height*4/Modelica.Constants.pi) "Diameter of heat storage" annotation (HideResult=true, Dialog(group="Storage"));
  parameter Modelica.Units.NonSI.Temperature_degC T_amb=15 "Assumed constant ambient temperature" annotation (HideResult=true, Dialog(group="Storage"));
  parameter Modelica.Units.SI.SurfaceCoefficientOfHeatTransfer k=0.08 "Coefficient of heat transfer through tank surface" annotation (HideResult=true, Dialog(group="Storage"));

  parameter Modelica.Units.SI.Power P_inst=5000 "Combined installed power" annotation (HideResult=true, Dialog(group="PV Parameters"));
  parameter Modelica.Units.SI.Power Pmpp=200 "Peak power of one module" annotation (HideResult=true, Dialog(group="PV Parameters"));
  parameter Modelica.Units.SI.Area Area=1.18 "Area of one complete module" annotation (HideResult=true, Dialog(group="PV Parameters"));
  parameter Real Strings=1 "Choose amount of strings" annotation (HideResult=true, Dialog(group="PV Parameters"));

  parameter Real GroundCoverageRatio=0.0 "ratio of covered ground of modules to area of modules" annotation (HideResult=true, Dialog(group="PV Parameters"));
  parameter Real LossesDC=4.44 "losses in % through connections, wiring, tracking error and mismatches" annotation (HideResult=true, Dialog(group="PV Parameters"));

  parameter Real Soiling=5 "Average annual losses of radiation in % due to soiling" annotation (HideResult=true, Dialog(group="Radiation Parameters"));
  parameter Real Albedo=0.25 "Average annual losses of radiation in % due to soiling" annotation (HideResult=true, Dialog(group="Radiation Parameters"));

  parameter Modelica.Units.SI.Angle longitude_local=Modelica.Units.Conversions.from_deg(11.55) "Longitude of the local position, east positive, 10 East for Hamburg" annotation (Dialog(group="Radiation Parameters"));
  parameter Modelica.Units.SI.Angle longitude_standard=Modelica.Units.Conversions.from_deg(15) "Needed for calculation of coordinated universal time (utc), 15 for central european time, 30 for central european summer time" annotation (Dialog(group="Radiation Parameters"));
  parameter Modelica.Units.NonSI.Time_day totaldays=365 "Total days of the year, standard=365, leap year=366" annotation (Dialog(group="Radiation Parameters"));
  parameter Modelica.Units.SI.Angle latitude=Modelica.Units.Conversions.from_deg(48.17) "Latitude of the local position, north posiive, 53,55 North for Hamburg" annotation (Dialog(group="Radiation Parameters"));

  parameter TransiEnt.Producer.Electrical.Photovoltaics.Advanced_PV.Characteristics.Generic_Characteristics_PVModule PVModuleCharacteristics=TransiEnt.Producer.Electrical.Photovoltaics.Advanced_PV.Characteristics.PVModule_Characteristics_Sanyo_HIT_200_BA3() "Characteristics of PV Module" annotation (
    HideResult=true,
    choicesAllMatching,
    Dialog(group="PV Parameters"));

  parameter Modelica.Units.SI.Angle Tilt=Modelica.Units.Conversions.from_deg(30) "Inclination of surface" annotation (HideResult=true, Dialog(group="Radiation Parameters"));
  parameter Modelica.Units.SI.Angle Azimuth=Modelica.Units.Conversions.from_deg(0) "Gyration of surface; Orientation: +90=West, -90=East, 0=South" annotation (HideResult=true, Dialog(group="Radiation Parameters"));

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

  TransiEnt.Storage.Heat.HotWaterStorage_constProp_L2.HotWaterStorage_constProp_L2 heatStorage1(
    useFluidPorts=false,
    T_s_max=328.15,
    T_s_min=298.15,
    d=0.75,
    height=0.513,
    T_amb=T_amb,
    k=k,
    T_start=328.15)  annotation (Placement(transformation(extent={{66,36},{86,56}})));

  Producer.Electrical.Photovoltaics.Advanced_PV.SinglePhasePVInverter                                            inverter(
    eta=0.98,
    cosphi=1,
    behavior=1,
    P_n=12000,
    P_PV=12000,
    Threshold=1.0,
    redeclare Basics.Interfaces.Electrical.ComplexPowerPort epp_AC)
                   annotation (Placement(transformation(
        extent={{9,-7},{-9,7}},
        rotation=90,
        origin={-111,-59})));

  TransiEnt.Components.Boundaries.Electrical.ComplexPower.PQBoundary     pQBoundary(    useInputConnectorQ=false, useInputConnectorP=true,
    cosphi_boundary=0.9)                                                                                                                   annotation (Placement(transformation(extent={{-70,-40},{-54,-24}})));

  Modelica.Blocks.Sources.RealExpression excessPV(y=pVModule2.epp.P + pVModule1.epp.P
         - pQBoundary.epp.P) annotation (Placement(transformation(
        extent={{7,-7},{-7,7}},
        rotation=90,
        origin={-39,17})));
  Modelica.Blocks.Math.Add add if heating and hotwater annotation (Placement(transformation(extent={{18,36},{32,50}})));
  Modelica.Blocks.Math.Add add1 if not hotwater annotation (Placement(transformation(extent={{-14,36},{-28,50}})));
  Producer.Heat.Power2Heat.ElectricBoiler.ElectricBoiler                    electricHeater(
    change_sign=true,
    usePelset=true,
    Q_flow_n=4500*0.95,
    eta=0.99,
    useFluidPorts=false,
    usePowerPort=true,
    redeclare connector PowerPortModel =
        Basics.Interfaces.Electrical.ComplexPowerPort,
    redeclare model PowerBoundaryModel =
        Components.Boundaries.Electrical.ComplexPower.PQBoundary,
    powerBoundary(useInputConnectorQ=false, cosphi_boundary=0.95)) annotation (Placement(transformation(extent={{52,-70},{72,-50}})));
  Modelica.Blocks.Math.Add add3 annotation (Placement(transformation(extent={{64,-46},{78,-32}})));

  Producer.Heat.Power2Heat.Heatpump.Heatpump                                                                  heatPump(
    usePowerPort=true,
    Q_flow_n=10500,
    useFluidPorts=false,
    useHeatPort=false,
    T_set=328.15,
    redeclare connector PowerPortModel =
        TransiEnt.Basics.Interfaces.Electrical.ComplexPowerPort,
    redeclare model PowerBoundaryModel =
        TransiEnt.Components.Boundaries.Electrical.ComplexPower.PQBoundary,
    Power(useInputConnectorQ=false, cosphi_boundary=0.95)) annotation (Placement(transformation(extent={{10,-22},{30,-2}})));
  TransiEnt.Consumer.Electrical.BatteryElectricVehicle       batteryElectricVehicle(
    vehicleEfficiency=15,
    P_max_BEV_drive=150000,
    P_max_BEV_charge=11000,
    C_Bat=277200000,
    P_chargingStation=11000,
    P_fast=50000,
    P_superfast=350000,
    useExternalControl=true,
    controlType="limit in Watt",
    redeclare model DistanceLocationTable =
        TransiEnt.Basics.Tables.ElectricGrid.Electromobility.DistanceLocationProfiles_family_15min
        (                                                                                                                               relativepath="emobility/building01.csv"),
    redeclare connector PowerPortModel =
        TransiEnt.Basics.Interfaces.Electrical.ComplexPowerPort,
    redeclare model PowerBoundaryModel =
        TransiEnt.Components.Boundaries.Electrical.ComplexPower.PQBoundary,
    Power(cosphi_boundary=0.95))                                                                             annotation (Placement(transformation(extent={{-50,-70},{-30,-50}})));
  Producer.Electrical.Photovoltaics.Advanced_PV.DNIDHI_Input.PVModule pVModule2(
    P_inst=6000,
    Pmpp=Pmpp,
    Area=Area,
    Strings=Strings,
    GroundCoverageRatio=GroundCoverageRatio,
    LossesDC=LossesDC,
    Soiling=Soiling,
    longitude_local=longitude_local,
    longitude_standard=longitude_standard,
    totaldays=totaldays,
    latitude=latitude,
    slope=Tilt,
    surfaceAzimuthAngle=Azimuth,
    reflectance_ground=Albedo)
    annotation (Placement(transformation(extent={{-74,46},{-94,66}})));
  Modelica.Blocks.Sources.RealExpression ambientTemperature(y=simCenter.ambientConditions.temperature.value) annotation (Placement(transformation(
        extent={{10,-6},{-10,6}},
        rotation=0,
        origin={-34,92})));
  Modelica.Blocks.Sources.RealExpression directSolarRadiation(y=simCenter.ambientConditions.directSolarRadiation.value) annotation (Placement(transformation(
        extent={{10,-6},{-10,6}},
        rotation=0,
        origin={-34,82})));
  Modelica.Blocks.Sources.RealExpression diffuseSolarRadiation(y=simCenter.ambientConditions.diffuseSolarRadiation.value) annotation (Placement(transformation(
        extent={{10,-6},{-10,6}},
        rotation=0,
        origin={-34,72})));
  Modelica.Blocks.Sources.RealExpression wind(y=simCenter.ambientConditions.wind.value) annotation (Placement(transformation(
        extent={{10,-7},{-10,7}},
        rotation=0,
        origin={-34,63})));
  Producer.Electrical.Photovoltaics.Advanced_PV.DNIDHI_Input.PVModule                        pVModule1(
    P_inst=6000,
    Pmpp=Pmpp,
    Area=Area,
    Strings=Strings,
    GroundCoverageRatio=GroundCoverageRatio,
    LossesDC=LossesDC,
    Soiling=Soiling,
    longitude_local=longitude_local,
    longitude_standard=longitude_standard,
    totaldays=totaldays,
    latitude=latitude,
    slope=Tilt,
    surfaceAzimuthAngle=Modelica.Units.Conversions.from_deg(180),
    reflectance_ground=Albedo)                   annotation (Placement(transformation(extent={{-74,76},{-94,96}})));
  Modelica.Blocks.Sources.RealExpression COP_HP(y=heatPump.COP) annotation (Placement(transformation(extent={{-96,0},{-78,18}})));
  Modelica.Blocks.Interfaces.RealInput P_SVE annotation (Placement(transformation(extent={{-166,-92},{-126,-52}})));
  replaceable Masterarbeit.Thesis_Final.Thesis_POC_Modelle.POC_strombedingtesEngpassmanagement_EMS.ControlHeatpump_PVoriented_invHPEMS controller constrainedby
    Masterarbeit.Thesis_Final.Thesis_POC_Modelle.POC_spannungsbedingtesEngpassmanagement.ControlHeatpump_PVoriented(
    P_elHeater=P_el_n,
    CalculatePHeater=true,
    Q_flow_n=heatPump.Q_flow_n,
    Delta_T_db=Delta_T_db) annotation (
    Dialog(group="System setup"),
    choicesAllMatching=true,
    Placement(transformation(extent={{-40,-20},{-20,0}})));
  Modelica.Blocks.Sources.RealExpression PV_PVSpeicher(y=inverter.epp_AC.P) annotation (Placement(transformation(extent={{-100,-26},{-82,-8}})));
  TransiEnt.Consumer.Heat.Profiles.HeatingCurve heatingCurve(
    T_room_set=295.15,
    T_amb_min=265.15,
    T_supply_max=313.15) annotation (Placement(transformation(extent={{-198,-38},{-178,-18}})));
  Modelica.Blocks.Sources.RealExpression Tset1(y=313.15)
                                                       annotation (Placement(transformation(extent={{-192,-60},{-174,-42}})));
  Modelica.Blocks.Math.Max max1 annotation (Placement(transformation(extent={{-150,-42},{-130,-22}})));
  replaceable Masterarbeit.Netz_Direktansteuerung.MaxSelfConsumption                                         controller1(zero1(y=0.9995)) if
                                                                                                                            battery constrainedby
    Masterarbeit.Netz_Direktansteuerung.MaxSelfConsumption                                                                                                                                                                                       "Operation strategy of the battery" annotation (
    Dialog(group="Battery Parameters"),
    choicesAllMatching=true,
    Placement(transformation(
        extent={{-8,-8},{8,8}},
        rotation=-90,
        origin={-130,40})));
  Modelica.Blocks.Sources.RealExpression p_PV(y=pVModule2.P_dc + pVModule1.P_dc)
    annotation (Placement(transformation(
        extent={{10,-9},{-10,9}},
        rotation=90,
        origin={-120,85})));
  Modelica.Blocks.Sources.RealExpression excessPV1(y=pQBoundary.epp.P + heatPump.epp.P + electricHeater.epp.P) annotation (Placement(transformation(
        extent={{8,-8},{-8,8}},
        rotation=90,
        origin={-138,84})));
  TransiEnt.Storage.Electrical.LithiumIonBattery
                    Storage(StorageModelParams=TransiEnt.Storage.Electrical.Specifications.LithiumIon(
              E_max=42840000,
              P_max_unload=5000,
              P_max_load=5000,
              eta_unload=1,
              eta_load=1), redeclare model CostModel =
        TransiEnt.Components.Statistics.ConfigurationData.StorageCostSpecs.LithiumIonBattery)
                     annotation (Placement(transformation(extent={{-141,-11},{-119,11}})));
  Modelica.Blocks.Sources.RealExpression storage_SOC(y=Storage.SOC.y) annotation (Placement(transformation(extent={{-182,46},{-164,64}})));
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

  if heating and hotwater then
    connect(add.y, heatStorage1.Q_flow_demand) annotation (Line(points={{32.7,43},{52,43},{52,28},{92,28},{92,46},{86,46}}, color={0,0,127}));
  elseif heating then
    connect(demand.heatingPowerDemand, heatStorage1.Q_flow_demand) annotation (Line(points={{0,100.48},{0,14},{98,14},{98,46},{86,46}}, color={0,127,127}));
  else
    connect(demand.hotWaterPowerDemand, heatStorage1.Q_flow_demand) annotation (Line(points={{-4.8,100.48},{-4.8,14},{98,14},{98,46},{86,46}}, color={0,127,127}));
  end if;

  if not hotwater then
  else
    connect(demand.electricPowerDemand, pQBoundary.P_el_set) annotation (Line(points={{4.68,100.48},{4.68,32},{-66.8,32},{-66.8,-22.4}}, color={0,127,127}));
  end if;

  connect(heatStorage1.SoC, controller.SoC) annotation (Line(points={{77.8,55.6},{72,55.6},{72,60},{-2,60},{-2,-4},{-6,-4},{-6,-14},{-39.4,-14}},
                                                                                                                                                color={0,0,127}));
  connect(demand.heatingPowerDemand, add.u2) annotation (Line(points={{0,100.48},{10,100.48},{10,38.8},{16.6,38.8}}, color={0,127,127}));
  connect(demand.hotWaterPowerDemand, add.u1) annotation (Line(points={{-4.8,100.48},{10,100.48},{10,47.2},{16.6,47.2}}, color={0,127,127}));

  connect(demand.electricPowerDemand, add1.u1) annotation (Line(points={{4.68,100.48},{4.68,100.48},{4.68,47.2},{-12.6,47.2}}, color={0,127,127}));
  connect(demand.hotWaterPowerDemand, add1.u2) annotation (Line(points={{-4.8,100.48},{-4.8,100.48},{-4.8,38.8},{-12.6,38.8}}, color={0,127,127}));

  connect(add3.y, heatStorage1.Q_flow_store) annotation (Line(points={{78.7,-39},{88,-39},{88,-16},{64,-16},{64,46},{66.6,46}}, color={0,0,127}));
  connect(excessPV.y, controller.PV_excess) annotation (Line(points={{-39,9.3},{-39,0.333333}},                color={0,0,127}));
  connect(heatStorage1.T_stor_out, controller.T) annotation (Line(points={{74.2,55.6},{74.2,68},{110,68},{110,26},{60,26},{60,22},{2,22},{2,4},{-46,4},{-46,-5},{-39.4,-5}},
                                                                                                                                                                   color={0,0,127}));
  connect(electricHeater.Q_flow_gen, add3.u2) annotation (Line(
      points={{72.6,-51.8},{72.6,-48},{56,-48},{56,-43.2},{62.6,-43.2}},
      color={175,0,0},
      pattern=LinePattern.Dash));
  connect(controller.P_set_electricHeater, electricHeater.P_el_set) annotation (Line(
      points={{-19.5,-14.75},{4,-14.75},{4,-28},{46,-28},{46,-62.4},{52.4,-62.4}},
      color={0,135,135},
      pattern=LinePattern.Dash));
  connect(pQBoundary.epp, epp) annotation (Line(
      points={{-70,-32},{-74,-32},{-74,-84},{-80,-84},{-80,-98}},
      color={28,108,200},
      thickness=0.5));
  connect(inverter.epp_AC, epp) annotation (Line(
      points={{-111,-68},{-111,-82},{-74,-82},{-74,-84},{-80,-84},{-80,-98}},
      color={28,108,200},
      thickness=0.5));
  connect(electricHeater.epp, epp) annotation (Line(
      points={{62,-70.2},{62,-82},{-80,-82},{-80,-98}},
      color={28,108,200},
      thickness=0.5));
  connect(heatPump.Heat_output, add3.u1) annotation (Line(
      points={{31.6,-6.2},{56,-6.2},{56,-34.8},{62.6,-34.8}},
      color={175,0,0},
      pattern=LinePattern.Dash));
  connect(heatPump.epp, epp) annotation (Line(
      points={{27.6,-22},{28,-22},{28,-82},{-80,-82},{-80,-98}},
      color={28,108,200},
      thickness=0.5));
  connect(batteryElectricVehicle.epp, epp) annotation (Line(
      points={{-30.2,-60.2},{-10,-60.2},{-10,-82},{-58,-82},{-58,-98}},
      color={28,108,200},
      thickness=0.5));
  connect(add1.y, pQBoundary.P_el_set) annotation (Line(points={{-28.7,43},{-66.8,43},{-66.8,-22.4}}, color={0,0,127}));
  connect(pVModule2.epp, inverter.epp_DC) annotation (Line(
      points={{-93.3,55.4},{-100,55.4},{-100,-6},{-106,-6},{-106,-44},{-111,-44},
          {-111,-50.18}},
      color={0,135,135},
      thickness=0.5));
  connect(pVModule1.epp, inverter.epp_DC) annotation (Line(
      points={{-93.3,85.4},{-100,85.4},{-100,-6},{-106,-6},{-106,-44},{-111,-44},{-111,-50.18}},
      color={0,135,135},
      thickness=0.5));
  connect(wind.y, pVModule2.WindSpeed_in) annotation (Line(points={{-45,63},{-46,
          63},{-46,62},{-48,62},{-48,48},{-72,48}}, color={0,0,127}));
  connect(pVModule2.DHI_in, diffuseSolarRadiation.y) annotation (Line(points={{
          -72,53.4},{-50,53.4},{-50,72},{-45,72}}, color={0,0,127}));
  connect(pVModule2.DNI_in, directSolarRadiation.y) annotation (Line(points={{-72,
          58.4},{-54,58.4},{-54,82},{-45,82}}, color={0,0,127}));
  connect(pVModule2.T_in, ambientTemperature.y) annotation (Line(points={{-72,
          64},{-56,64},{-56,92},{-45,92}}, color={0,0,127}));
  connect(pVModule1.T_in, ambientTemperature.y) annotation (Line(points={{-72,94},{-56,94},{-56,92},{-45,92}}, color={0,0,127}));
  connect(pVModule1.DNI_in, directSolarRadiation.y) annotation (Line(points={{-72,88.4},{-58,88.4},{-58,82},{-45,82}}, color={0,0,127}));
  connect(pVModule1.DHI_in, diffuseSolarRadiation.y) annotation (Line(points={{-72,83.4},{-60,83.4},{-60,72},{-45,72}}, color={0,0,127}));
  connect(pVModule1.WindSpeed_in, pVModule2.WindSpeed_in) annotation (Line(
        points={{-72,78},{-62,78},{-62,70},{-48,70},{-48,48},{-72,48}}, color={
          0,0,127}));
  connect(controller.P_EV, batteryElectricVehicle.P_limit) annotation (Line(points={{-19.4,-18.3333},{-12,-18.3333},{-12,-74},{-58,-74},{-58,-60.5},{-50.9,-60.5}},
                                                                                                                                                          color={0,0,127}));
  connect(COP_HP.y, controller.COP) annotation (Line(points={{-77.1,9},{-50,9},{-50,-3.83333},{-75,-3.83333}},
                                                                                                       color={0,0,127}));
  connect(controller.P_SVE, P_SVE) annotation (Line(points={{-75,0},{-72,0},{-72,-4},{-108,-4},{-108,-42},{-124,-42},{-124,-48},{-122,-48},{-122,-72},{-146,-72}},
                                                                                                                                                          color={0,0,127}));
  connect(controller.PV_Speicher, PV_PVSpeicher.y) annotation (Line(points={{-74.8,-16.6667},{-81.1,-17}},                                                                     color={0,0,127}));
  connect(max1.y, controller.T_set) annotation (Line(points={{-129,-32},{-78,-32},{-78,-9.5},{-39.2,-9.5}}, color={0,0,127}));
  connect(Tset1.y, max1.u2) annotation (Line(points={{-173.1,-51},{-164,-51},{-164,-38},{-152,-38}}, color={0,0,127}));
  connect(heatingCurve.T_supply, max1.u1) annotation (Line(points={{-177.6,-26},{-152,-26}}, color={0,0,127}));
  connect(p_PV.y,controller1. P_PV) annotation (Line(points={{-120,74},{-120,54},{-125.2,54},{-125.2,47.52}}, color={0,0,127}));
  connect(excessPV1.y,controller1. P_Consumer) annotation (Line(points={{-138,75.2},{-138,54},{-134.8,54},{-134.8,47.36}}, color={0,0,127}));
  connect(controller1.P_set_battery,Storage. P_set) annotation (Line(points={{-130,32},{-130,10.34}},color={0,0,127}));
  connect(storage_SOC.y,controller1. SOC) annotation (Line(points={{-163.1,55},{-140.72,55},{-140.72,48.16}}, color={0,0,127}));
  connect(Storage.epp, inverter.epp_DC) annotation (Line(
      points={{-119,0},{-112,0},{-112,-6},{-106,-6},{-106,-44},{-111,-44},{-111,-50.18}},
      color={0,135,135},
      thickness=0.5));
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
