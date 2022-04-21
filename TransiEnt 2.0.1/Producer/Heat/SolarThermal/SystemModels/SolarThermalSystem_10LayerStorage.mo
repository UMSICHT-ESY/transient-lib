﻿within TransiEnt.Producer.Heat.SolarThermal.SystemModels;
model SolarThermalSystem_10LayerStorage "Energy based combination of solar collector, controller, boiler and thermal storage with three layers"



//________________________________________________________________________________//
// Component of the TransiEnt Library, version: 2.0.1                             //
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
// Gas- und Wärme-Institut Essen						  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//






  // _____________________________________________
  //
  //          Imports and Class Hierarchy
  // _____________________________________________

  outer TransiEnt.SimCenter simCenter;
  extends TransiEnt.Basics.Icons.Model;

  import FT = TransiEnt.Basics.Types.FuelType;

  // _____________________________________________
  //
  //           Parameters
  // _____________________________________________

  // Boiler
  parameter FT fuel=FT.Gas "Choice of fuel" annotation (HideResult=true, Dialog(group="Boiler"));
  parameter Boolean useGasPort=if fuel == FT.Gas then true else false "True if gas port shall be used" annotation (choices(checkBox=true), Dialog(group="Boiler", enable=fuel == FT.Gas));
  parameter TILMedia.VLEFluidTypes.BaseVLEFluid GasMedium=simCenter.gasModel1 "|Boiler|Fuel gas medium";
  parameter SI.HeatFlowRate Q_flow_n_boiler=20000 "Nominal heating power of the gas boiler" annotation (Dialog(group="Boiler"));
  parameter SI.Efficiency eta=1.05 "Boiler's overall efficiency" annotation (Dialog(group="Boiler"));
  parameter TransiEnt.Basics.Types.TypeOfPrimaryEnergyCarrierHeat typeOfPrimaryEnergyCarrier=if fuel == FT.Gas then TransiEnt.Basics.Types.TypeOfPrimaryEnergyCarrierHeat.NaturalGas elseif fuel == FT.Oil then TransiEnt.Basics.Types.TypeOfPrimaryEnergyCarrierHeat.Oil elseif fuel == FT.Pellets then TransiEnt.Basics.Types.TypeOfPrimaryEnergyCarrierHeat.Biomass else 0 "Type of primary energy carrier for co2 emissions global statistics" annotation (Dialog(group="Boiler"));
  replaceable model BoilerCostModel = TransiEnt.Components.Statistics.ConfigurationData.PowerProducerCostSpecs.GasBoiler annotation (__Dymola_choicesAllMatching=true, Dialog(group="Boiler"));
  parameter SI.SpecificEnthalpy HoC_fuel=if fuel == FT.Gas then simCenter.HeatingValue_natGas elseif fuel == FT.Oil then simCenter.HeatingValue_LightOil elseif fuel == FT.Pellets then simCenter.HeatingValue_Wood else 0 "heat of combustion of fuel used" annotation (Dialog(group="Boiler"));

  //Configuration
  parameter Boolean SpaceHeating=true "Does the solar heating system provide energy for space heating?" annotation (choices(checkBox=true));

  //System
  parameter SI.Temperature T_room=288 "Temperature of the installation room";
  parameter SI.Temperature T_return=308.15 "Return temperature of the heating system";
  parameter SI.Temperature T_boiler=60 + 273.15 "Temperature setpoint of the boiler";
  parameter SI.Volume Volume_tank=2 "Volume of the storage tank" annotation (Dialog(group="Storage"));
  parameter Real p_Volume[storage.N_cv]={0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1} "Proportion of the total volume for the three parts of the tank" annotation (Dialog(group="Storage"));
  parameter SI.Temperature T_start[storage.N_cv]=fill(273.15 + 60, storage.N_cv) "Temperatures at initalization" annotation (Dialog(group="Storage"));
  parameter SI.Length h_tank=1 "height of tank" annotation (Dialog(group="Storage"));
  parameter SI.CoefficientOfHeatTransfer U_wall=0.5 "Coefficient of heat transfer from wall to ambient " annotation (Dialog(group="Storage"));
  parameter SI.ThermalConductivity k=0.6 "Thermal conductivity of fluid in storage" annotation (Dialog(group="Storage"));
  parameter SI.Density rho=1e3 "Density of fluid in storage" annotation (Dialog(group="Storage"));
  parameter SI.SpecificHeatCapacity c_v=4.185e3 "Heat capacity of fluid in storage" annotation (Dialog(group="Storage"));

  //Collector
  parameter SI.Irradiance G_min=150 "minimum Irradiance before collector is working" annotation (Dialog(group="Collector"));
  parameter SI.Temperature T_set=348.15 "Temperature set point for controller" annotation (Dialog(group="Collector"));
  parameter SI.Temperature T_max=273.15 + 95 "maximum input temperature for collector switch-off" annotation (Dialog(group="Collector"));
  parameter SI.HeatFlowRate Q_flow_n=100e3 "Nominal heat flow rate of the collector (for cost calculation)" annotation (Dialog(group="Collector"));
  parameter SI.Area area=5 "Aperture area" annotation (Dialog(group="Collector"));
  parameter Real c_eff(unit="J/(m2.K)") = 5000 "Effective thermal capacity of the collector" annotation (Dialog(group="Collector"));
  parameter Real eta_0=0.793 "Zero-loss collector efficiency" annotation (Dialog(group="Collector"));
  parameter Real a1(unit="W/(m2.K)") = 4.04 "Heat loss coefficient at (T_m - T_amb) = 0" annotation (Dialog(group="Collector"));
  parameter Real a2(unit="W/(m2.K2)") = 0.0182 "Temperature dependent heat loss coefficient" annotation (Dialog(group="Collector"));
  parameter SI.Angle longitude_standard=Modelica.Units.Conversions.from_deg(15) "needed for calculation of coordinated universal time (utc), 15 for central european time, 30 for central european summer time" annotation (Dialog(group="Collector"));
  parameter Modelica.Units.NonSI.Time_day totaldays=365 "total days of the year, standard=365, leap year=366" annotation (Dialog(group="Collector"));
  parameter SI.Angle latitude=Modelica.Units.Conversions.from_deg(53.55) "latitude of the local position, north posiive, 53,55 North for Hamburg" annotation (Dialog(group="Collector"));
  parameter SI.Angle slope=Modelica.Units.Conversions.from_deg(53.55) "slope of the tilted surface, assumption" annotation (Dialog(group="Collector"));
  parameter SI.Angle surfaceAzimuthAngle=0 "surface azimuth angle" annotation (Dialog(group="Collector"));
  replaceable model Skymodel = TransiEnt.Producer.Heat.SolarThermal.Base.Skymodel_HDKR constrainedby TransiEnt.Producer.Heat.SolarThermal.Base.SkymodelBase "|Collector|choose between HDKR and isotropic sky model" annotation (choicesAllMatching=true, Dialog(tab="Irradiance", group="Skymodel"));
  parameter Real reflectance_ground=0.2 "reflectance of the ground" annotation (Dialog(group="Collector"));
  parameter Boolean direct_normal=true "Is the direct irradiance measured on a surface normal to irradiance?" annotation (Dialog(group="Collector"));
  parameter SI.Angle longitude_local=Modelica.Units.Conversions.from_deg(10) "longitude of the local position, east positive, 10 East for Hamburg" annotation (Dialog(group="Collector"));

  // _____________________________________________
  //
  //           Variables
  // _____________________________________________

  SI.Energy E_heating;
  SI.Energy E_hotwater;
  SI.Energy E_solar;
  SI.Energy E_boiler;

  Real SolarFraction=E_solar/(E_hotwater + E_heating + 0.001);

  SI.MassFlowRate m_flow_consumer;
  SI.MassFlowRate m_flow_hotwater;
  SI.Power Q_flow_boiler;

  SI.HeatFlowRate HeatingSolar;

  Real solarCoverage;

  // _____________________________________________
  //
  //           Interfaces
  // _____________________________________________

  TransiEnt.Basics.Interfaces.Gas.RealGasPortIn gasPortIn(Medium=GasMedium) if     fuel==FT.Gas and useGasPort annotation (Placement(transformation(extent={{96,-146},{116,-126}}), iconTransformation(extent={{94,-148},{116,-126}})));
  TransiEnt.Basics.Interfaces.Thermal.HeatFlowRateIn Q_flow_demand_heating annotation (Placement(transformation(
        extent={{-14,-14},{14,14}},
        rotation=270,
        origin={-14,122}), iconTransformation(
        extent={{-13,-13},{13,13}},
        rotation=270,
        origin={-39,95})));
  TransiEnt.Basics.Interfaces.Thermal.HeatFlowRateIn Q_flow_demand_hotwater annotation (Placement(transformation(
        extent={{-14,-14},{14,14}},
        rotation=270,
        origin={20,122}), iconTransformation(
        extent={{-13,-13},{13,13}},
        rotation=270,
        origin={41,95})));
  // _____________________________________________
  //
  //           Instances of other Classes
  // _____________________________________________

  Modelica.Blocks.Sources.RealExpression heatFlowRate_boiler(y=Q_flow_boiler) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={50,-88})));

  Modelica.Blocks.Sources.RealExpression T_in(y=storage.port[10].T) annotation (Placement(transformation(
        extent={{-11.5,-8.5},{11.5,8.5}},
        rotation=0,
        origin={75.5,16.5})));

  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T=T_room) annotation (Placement(transformation(
        extent={{4,-4},{-4,4}},
        rotation=90,
        origin={-128,28})));

  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow1 annotation (Placement(transformation(extent={{-82,82},{-96,96}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow2 annotation (Placement(transformation(extent={{-82,60},{-96,74}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow3 annotation (Placement(transformation(extent={{-82,40},{-96,54}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow4 annotation (Placement(transformation(extent={{-80,14},{-94,28}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow5 annotation (Placement(transformation(extent={{-82,-8},{-96,6}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow_6 annotation (Placement(transformation(extent={{-82,-26},{-96,-12}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow7 annotation (Placement(transformation(extent={{-82,-48},{-96,-34}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow8 annotation (Placement(transformation(extent={{-82,-76},{-96,-62}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow9 annotation (Placement(transformation(extent={{-82,-106},{-96,-92}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow10 annotation (Placement(transformation(extent={{-82,-128},{-96,-114}})));
  Modelica.Blocks.Math.Add add10 annotation (Placement(transformation(extent={{-60,-126},{-70,-116}})));
  Modelica.Blocks.Math.Add add9 annotation (Placement(transformation(extent={{-60,-102},{-70,-92}})));
  Modelica.Blocks.Math.Add add4 annotation (Placement(transformation(extent={{-56,12},{-66,22}})));
  Modelica.Blocks.Math.Add3 add5 annotation (Placement(transformation(extent={{-58,-6},{-70,6}})));
  Modelica.Blocks.Math.Add3 add6 annotation (Placement(transformation(extent={{-60,-26},{-70,-16}})));
  Modelica.Blocks.Math.Add add7 annotation (Placement(transformation(extent={{-60,-46},{-70,-36}})));
  Modelica.Blocks.Math.Add add8 annotation (Placement(transformation(extent={{-62,-72},{-72,-62}})));
  Modelica.Blocks.Math.Add add3 annotation (Placement(transformation(extent={{-58,38},{-68,48}})));
  Modelica.Blocks.Math.Add3 add2 annotation (Placement(transformation(extent={{-56,62},{-68,74}})));
  Modelica.Blocks.Math.Add add1 annotation (Placement(transformation(extent={{-56,84},{-66,94}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_boiler2(y=min(Q_flow_n_boiler, max(0, 0.5*4190*(T_boiler - storage.port[2].T)))) annotation (Placement(transformation(extent={{28,56},{12,68}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_DHW2(y=-(Q_flow_demand_hotwater + Q_flow_DHW10.y + Q_flow_DHW9.y + Q_flow_DHW8.y + Q_flow_DHW7.y + Q_flow_DHW6.y + Q_flow_DHW5.y + Q_flow_DHW4.y + Q_flow_DHW3.y)) annotation (Placement(transformation(extent={{2,62},{-14,74}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_heating2(y=-HeatingSolar - Q_flow_heating3.y - Q_flow_heating4.y - Q_flow_heating5.y - Q_flow_heating6.y) annotation (Placement(transformation(extent={{-20,68},{-36,80}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_boiler1(y=min(Q_flow_n_boiler, max(0, 0.05*4190*(T_boiler - storage.port[1].T)))) annotation (Placement(transformation(extent={{-6,82},{-22,94}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_heating1(y=0) annotation (Placement(transformation(extent={{-24,92},{-40,104}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_DHW3(y=max(-Q_flow_demand_hotwater - Q_flow_DHW10.y - Q_flow_DHW9.y - Q_flow_DHW8.y - Q_flow_DHW7.y - Q_flow_DHW6.y - Q_flow_DHW5.y - Q_flow_DHW4.y, min(0, -m_flow_hotwater*4185*(storage.port[3].T - storage.port[2].T)))) annotation (Placement(transformation(extent={{-16,40},{-32,52}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_heating3(y=max(-HeatingSolar - Q_flow_heating6.y - Q_flow_heating5.y - Q_flow_heating4.y, -m_flow_consumer*4185*(storage.port[3].T - storage.port[4].T))) annotation (Placement(transformation(extent={{6,34},{-10,46}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_heating4(y=max(-HeatingSolar - Q_flow_heating6.y - Q_flow_heating5.y, -m_flow_consumer*4185*(storage.port[4].T - storage.port[5].T))) annotation (Placement(transformation(extent={{-20,14},{-36,26}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_DHW4(y=max(-Q_flow_demand_hotwater - Q_flow_DHW10.y - Q_flow_DHW9.y - Q_flow_DHW8.y - Q_flow_DHW7.y - Q_flow_DHW6.y - Q_flow_DHW5.y, min(0, -m_flow_hotwater*4185*(storage.port[4].T - storage.port[5].T)))) annotation (Placement(transformation(extent={{4,8},{-12,20}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_heating5(y=max(-HeatingSolar - Q_flow_heating6.y, -m_flow_consumer*4185*(storage.port[5].T - storage.port[6].T))) annotation (Placement(transformation(extent={{-18,0},{-34,12}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_solar5(y=max(0, min(-solarCollector.Q_flow_out, controller.P_drive*4185*(solarCollector.T_out - storage.port[5].T)))) annotation (Placement(transformation(extent={{10,-6},{-6,6}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_DHW5(y=max(-Q_flow_demand_hotwater - Q_flow_DHW10.y - Q_flow_DHW9.y - Q_flow_DHW8.y - Q_flow_DHW7.y - Q_flow_DHW6.y, min(0, -m_flow_hotwater*4185*(storage.port[5].T - storage.port[6].T)))) annotation (Placement(transformation(extent={{38,-14},{22,-2}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_DHW6(y=max(-Q_flow_demand_hotwater - Q_flow_DHW10.y - Q_flow_DHW9.y - Q_flow_DHW8.y - Q_flow_DHW7.y, min(0, -m_flow_hotwater*4185*(storage.port[6].T - storage.port[7].T)))) annotation (Placement(transformation(extent={{14,-32},{-2,-20}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_solar6(y=min(-solarCollector.Q_flow_out - Q_flow_solar5.y, controller.P_drive*4185*(storage.port[5].T - storage.port[6].T))) annotation (Placement(transformation(extent={{-8,-26},{-24,-14}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_heating6(y=max(-HeatingSolar, -m_flow_consumer*4185*(storage.port[6].T - T_return))) annotation (Placement(transformation(extent={{-28,-22},{-44,-10}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_solar7(y=min(-solarCollector.Q_flow_out - Q_flow_solar5.y - Q_flow_solar6.y, controller.P_drive*4185*(storage.port[6].T - storage.port[7].T))) annotation (Placement(transformation(extent={{-28,-48},{-44,-36}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_DHW7(y=max(-Q_flow_demand_hotwater - Q_flow_DHW10.y - Q_flow_DHW9.y - Q_flow_DHW8.y, min(0, -m_flow_hotwater*4185*(storage.port[7].T - storage.port[8].T)))) annotation (Placement(transformation(extent={{10,-52},{-6,-40}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_DHW8(y=max(-Q_flow_demand_hotwater - Q_flow_DHW10.y - Q_flow_DHW9.y, min(0, -m_flow_hotwater*4185*(storage.port[8].T - storage.port[9].T)))) annotation (Placement(transformation(extent={{10,-78},{-6,-66}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_solar8(y=min(-solarCollector.Q_flow_out - Q_flow_solar5.y - Q_flow_solar6.y - Q_flow_solar7.y, controller.P_drive*4185*(storage.port[7].T - storage.port[8].T))) annotation (Placement(transformation(extent={{-22,-72},{-38,-60}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_solar9(y=min(-solarCollector.Q_flow_out - Q_flow_solar5.y - Q_flow_solar6.y - Q_flow_solar7.y - Q_flow_solar8.y, controller.P_drive*4185*(storage.port[8].T - storage.port[9].T))) annotation (Placement(transformation(extent={{-22,-92},{-38,-80}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_DHW9(y=max(-Q_flow_demand_hotwater - Q_flow_DHW10.y, min(0, -m_flow_hotwater*4185*(storage.port[9].T - storage.port[10].T)))) annotation (Placement(transformation(extent={{-2,-98},{-18,-86}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_solar10(y=min(-solarCollector.Q_flow_out - Q_flow_solar5.y - Q_flow_solar6.y - Q_flow_solar7.y - Q_flow_solar8.y - Q_flow_solar9.y, -controller.P_drive*4185*(storage.port[9].T - storage.port[10].T))) annotation (Placement(transformation(extent={{-18,-114},{-34,-102}})));
  Modelica.Blocks.Sources.RealExpression Q_flow_DHW10(y=max(-Q_flow_demand_hotwater, min(0, -m_flow_hotwater*4185*(storage.port[10].T - 12 - 273.15)))) annotation (Placement(transformation(extent={{22,-120},{6,-108}})));

  //Storage
  TransiEnt.Storage.Heat.HotWaterStorage_constProp_L4.HotWaterStorage_constProp_L4 storage(
    N_cv=10,
    useFluidPorts=false,
    V=Volume_tank,
    p_Volume=p_Volume,
    h=h_tank,
    T_start=T_start,
    U_wall=U_wall,
    k=k,
    rho=rho,
    c_v=c_v) annotation (Placement(transformation(extent={{-140,-14},{-118,8}})));

  //Collector and Controller
  TransiEnt.Producer.Heat.SolarThermal.SolarCollector_L1_constProp solarCollector(
    G_min=controller.G_min,
    Q_flow_n=Q_flow_n,
    area=area,
    eta_0=eta_0,
    a1=a1,
    a2=a2,
    c_eff=c_eff,
    useFluidPorts=false,
    longitude_local=longitude_local,
    longitude_standard=longitude_standard,
    totaldays=totaldays,
    latitude=latitude,
    slope=slope,
    surfaceAzimuthAngle=surfaceAzimuthAngle,
    redeclare model Skymodel = Skymodel,
    reflectance_ground=reflectance_ground,
    direct_normal=direct_normal) annotation (Placement(transformation(extent={{90,-28},{108,-10}})));

  TransiEnt.Producer.Heat.SolarThermal.Control.ControllerPumpSolarCollectorTandG controller(
    T_set=T_set,
    G_min=G_min,
    T_stor_max=T_max,
    P_drive_min(k=controller.m_flow_min)) annotation (Placement(transformation(extent={{102,30},{128,50}})));

  //Boiler
  TransiEnt.Producer.Heat.Gas2Heat.SimpleGasBoiler.SimpleBoiler boiler(
    useFluidPorts=false,
    useHeatPort=false,
    useGasPort=useGasPort,
    change_sign=true,
    gasMedium=GasMedium,
    HoC_fuel=HoC_fuel,
    eta=eta,
    Q_flow_n=Q_flow_n_boiler,
    typeOfPrimaryEnergyCarrier=if fuel == FT.Gas then TransiEnt.Basics.Types.TypeOfPrimaryEnergyCarrierHeat.NaturalGas elseif fuel == FT.Oil then TransiEnt.Basics.Types.TypeOfPrimaryEnergyCarrierHeat.Oil else TransiEnt.Basics.Types.TypeOfPrimaryEnergyCarrierHeat.Biomass,
    redeclare model BoilerCostModel = BoilerCostModel) annotation (Placement(transformation(extent={{62,-116},{82,-96}})));

equation

  // _____________________________________________
  //
  //            Characteristic equations
  // _____________________________________________

  Q_flow_solar5.y + Q_flow_solar6.y + Q_flow_solar7.y + Q_flow_solar8.y + Q_flow_solar9.y + Q_flow_solar10.y = der(E_solar);
  Q_flow_boiler = der(E_boiler);
  Q_flow_demand_heating = der(E_heating);
  -Q_flow_DHW2.y - Q_flow_DHW3.y - Q_flow_DHW4.y - Q_flow_DHW5.y - Q_flow_DHW6.y - Q_flow_DHW7.y - Q_flow_DHW8.y - Q_flow_DHW9.y - Q_flow_DHW10.y = der(E_hotwater);

  solarCoverage = if SpaceHeating then E_solar/(E_heating + E_hotwater + 0.001) else E_solar/(E_hotwater + 0.001);

  m_flow_hotwater = Q_flow_demand_hotwater/(4185*(storage.port[1].T - (12 + 273.15)));

  if SpaceHeating == true then
    HeatingSolar = Q_flow_demand_heating;
    m_flow_consumer = Q_flow_demand_heating/(4185*(storage.port[1].T - T_return));
    Q_flow_boiler = Q_flow_boiler1.y + Q_flow_boiler2.y;
  else
    HeatingSolar = 0;
    m_flow_consumer = 0;
    Q_flow_boiler = Q_flow_boiler1.y + Q_flow_boiler2.y + Q_flow_demand_heating;
  end if;

 // _____________________________________________
 //
 //            Connect statements
 // _____________________________________________

  connect(storage.heatPortAmbient, fixedTemperature.port) annotation (Line(points={{-129,6.35},{-128,6.35},{-128,24}}, color={191,0,0}));

  connect(T_in.y, controller.T_in) annotation (Line(points={{88.15,16.5},{92,16.5},{92,42},{103.733,42}}, color={0,0,127}));
  connect(T_in.y, controller.T_stor) annotation (Line(points={{88.15,16.5},{92,16.5},{92,30},{103.733,30}}, color={0,0,127}));
  connect(controller.G_total, solarCollector.G) annotation (Line(points={{103.733,34.1667},{98,34.1667},{98,-4},{106.2,-4},{106.2,-10.9}}, color={0,0,127}));
  connect(solarCollector.T_out, controller.T_out) annotation (Line(points={{104.4,-10.9},{104.4,-12},{104,-12},{104,-6},{96,-6},{96,38.3333},{103.733,38.3333}}, color={0,0,127}));

  connect(storage.port[1], prescribedHeatFlow1.port) annotation (Line(points={{-118.88,2.94},{-118,2.94},{-118,4},{-108,4},{-108,90},{-96,90},{-96,89}}, color={191,0,0}));
  connect(prescribedHeatFlow1.Q_flow, add1.y) annotation (Line(points={{-82,89},{-66.5,89}}, color={0,0,127}));
  connect(Q_flow_heating1.y, add1.u1) annotation (Line(points={{-40.8,98},{-44.4,98},{-44.4,92},{-55,92}}, color={0,0,127}));
  connect(Q_flow_boiler1.y, add1.u2) annotation (Line(points={{-22.8,88},{-38,88},{-38,86},{-55,86}}, color={0,0,127}));
  connect(Q_flow_heating2.y, add2.u1) annotation (Line(points={{-36.8,74},{-44,74},{-44,72.8},{-54.8,72.8}}, color={0,0,127}));
  connect(Q_flow_DHW2.y, add2.u2) annotation (Line(points={{-14.8,68},{-54.8,68}}, color={0,0,127}));
  connect(Q_flow_boiler2.y, add2.u3) annotation (Line(points={{11.2,62},{-24,62},{-24,63.2},{-54.8,63.2}}, color={0,0,127}));
  connect(prescribedHeatFlow2.port, storage.port[2]) annotation (Line(points={{-96,67},{-108,67},{-108,3.16},{-118.88,3.16}}, color={191,0,0}));
  connect(prescribedHeatFlow2.Q_flow, add2.y) annotation (Line(points={{-82,67},{-76,67},{-76,68},{-68.6,68}}, color={0,0,127}));
  connect(prescribedHeatFlow3.port, storage.port[3]) annotation (Line(points={{-96,47},{-96,44},{-108,44},{-108,4},{-118,4},{-118,3.38},{-118.88,3.38}}, color={191,0,0}));
  connect(prescribedHeatFlow3.Q_flow, add3.y) annotation (Line(points={{-82,47},{-76,47},{-76,43},{-68.5,43}}, color={0,0,127}));
  connect(storage.port[4], prescribedHeatFlow4.port) annotation (Line(points={{-118.88,3.6},{-108,3.6},{-108,16},{-102,16},{-102,21},{-94,21}}, color={191,0,0}));
  connect(add3.u1, Q_flow_DHW3.y) annotation (Line(points={{-57,46},{-32.8,46}}, color={0,0,127}));
  connect(Q_flow_heating3.y, add3.u2) annotation (Line(points={{-10.8,40},{-57,40}}, color={0,0,127}));
  connect(Q_flow_heating4.y, add4.u1) annotation (Line(points={{-36.8,20},{-55,20}}, color={0,0,127}));
  connect(add4.u2, Q_flow_DHW4.y) annotation (Line(points={{-55,14},{-12.8,14}}, color={0,0,127}));
  connect(prescribedHeatFlow4.Q_flow, add4.y) annotation (Line(points={{-80,21},{-74,21},{-74,17},{-66.5,17}}, color={0,0,127}));
  connect(storage.port[5], prescribedHeatFlow5.port) annotation (Line(points={{-118.88,3.82},{-106.44,3.82},{-106.44,-1},{-96,-1}}, color={191,0,0}));
  connect(prescribedHeatFlow5.Q_flow, add5.y) annotation (Line(points={{-82,-1},{-75,-1},{-75,0},{-70.6,0}}, color={0,0,127}));
  connect(add5.u1, Q_flow_heating5.y) annotation (Line(points={{-56.8,4.8},{-42.5,4.8},{-42.5,6},{-34.8,6}}, color={0,0,127}));
  connect(add5.u2, Q_flow_solar5.y) annotation (Line(points={{-56.8,0},{-6.8,0}}, color={0,0,127}));
  connect(add5.u3, Q_flow_DHW5.y) annotation (Line(points={{-56.8,-4.8},{-21.5,-4.8},{-21.5,-8},{21.2,-8}}, color={0,0,127}));
  connect(add6.u1, Q_flow_heating6.y) annotation (Line(points={{-59,-17},{-52.5,-17},{-52.5,-16},{-44.8,-16}}, color={0,0,127}));
  connect(add6.u2, Q_flow_solar6.y) annotation (Line(points={{-59,-21},{-41.5,-21},{-41.5,-20},{-24.8,-20}}, color={0,0,127}));
  connect(add6.u3, Q_flow_DHW6.y) annotation (Line(points={{-59,-25},{-30.5,-25},{-30.5,-26},{-2.8,-26}}, color={0,0,127}));
  connect(add6.y, prescribedHeatFlow_6.Q_flow) annotation (Line(points={{-70.5,-21},{-76.25,-21},{-76.25,-19},{-82,-19}}, color={0,0,127}));
  connect(prescribedHeatFlow_6.port, storage.port[6]) annotation (Line(points={{-96,-19},{-108,-19},{-108,4.04},{-118.88,4.04}}, color={191,0,0}));
  connect(prescribedHeatFlow7.port, storage.port[7]) annotation (Line(points={{-96,-41},{-108,-41},{-108,4.26},{-118.88,4.26}}, color={191,0,0}));
  connect(prescribedHeatFlow7.Q_flow, add7.y) annotation (Line(points={{-82,-41},{-70.5,-41}}, color={0,0,127}));
  connect(add7.u1, Q_flow_solar7.y) annotation (Line(points={{-59,-38},{-50,-38},{-50,-42},{-44.8,-42}}, color={0,0,127}));
  connect(add7.u2, Q_flow_DHW7.y) annotation (Line(points={{-59,-44},{-35.5,-44},{-35.5,-46},{-6.8,-46}}, color={0,0,127}));
  connect(add8.u1, Q_flow_solar8.y) annotation (Line(points={{-61,-64},{-38.8,-64},{-38.8,-66}}, color={0,0,127}));
  connect(add8.u2, Q_flow_DHW8.y) annotation (Line(points={{-61,-70},{-36,-70},{-36,-74},{-6.8,-74},{-6.8,-72}}, color={0,0,127}));
  connect(add9.u1, Q_flow_solar9.y) annotation (Line(points={{-59,-94},{-50,-94},{-50,-86},{-38.8,-86}}, color={0,0,127}));
  connect(add9.u2, Q_flow_DHW9.y) annotation (Line(points={{-59,-100},{-38,-100},{-38,-92},{-18.8,-92}}, color={0,0,127}));
  connect(add10.u1, Q_flow_solar10.y) annotation (Line(points={{-59,-118},{-48,-118},{-48,-108},{-34.8,-108}}, color={0,0,127}));
  connect(add10.u2, Q_flow_DHW10.y) annotation (Line(points={{-59,-124},{-26,-124},{-26,-116},{5.2,-116},{5.2,-114}}, color={0,0,127}));
  connect(storage.port[8], prescribedHeatFlow8.port) annotation (Line(points={{-118.88,4.48},{-118,4.48},{-118,4},{-108,4},{-108,-68},{-96,-68},{-96,-69}}, color={191,0,0}));
  connect(storage.port[9], prescribedHeatFlow9.port) annotation (Line(points={{-118.88,4.7},{-118.88,2},{-108,2},{-108,-94},{-96,-94},{-96,-99}}, color={191,0,0}));
  connect(storage.port[10], prescribedHeatFlow10.port) annotation (Line(points={{-118.88,4.92},{-118.88,0},{-108,0},{-108,-120},{-96,-120},{-96,-121}}, color={191,0,0}));
  connect(prescribedHeatFlow10.Q_flow, add10.y) annotation (Line(points={{-82,-121},{-70.5,-121}}, color={0,0,127}));
  connect(prescribedHeatFlow9.Q_flow, add9.y) annotation (Line(points={{-82,-99},{-75,-99},{-75,-97},{-70.5,-97}}, color={0,0,127}));
  connect(prescribedHeatFlow8.Q_flow, add8.y) annotation (Line(points={{-82,-69},{-77,-69},{-77,-67},{-72.5,-67}}, color={0,0,127}));
  connect(heatFlowRate_boiler.y, boiler.Q_flow_set) annotation (Line(points={{61,-88},{82,-88},{82,-96},{72,-96}}, color={0,0,127}));
  connect(boiler.gasIn, gasPortIn) annotation (Line(
      points={{72.2,-116},{88,-116},{88,-136},{106,-136}},
      color={255,255,0},
      thickness=1.5));
  connect(controller.P_drive, solarCollector.m_flow) annotation (Line(
      points={{103.733,45},{54,45},{54,-2},{90.63,-2},{90.63,-10.81}},
      color={0,135,135},
      pattern=LinePattern.Dash));
  connect(T_in.y, solarCollector.T_inflow) annotation (Line(points={{88.15,16.5},{92.79,16.5},{92.79,-9.91}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-160,-140},
            {140,120}}),                                        graphics={
        Line(
          points={{-20,36},{-34,44}},
          color={0,0,0},
          smooth=Smooth.None),
        Line(
          points={{16,50},{-40,-58}},
          smooth=Smooth.None,
          color={255,255,255}),
        Line(
          points={{34,50},{-22,-58}},
          smooth=Smooth.None,
          color={255,255,255}),
        Line(
          points={{50,50},{-6,-58}},
          smooth=Smooth.None,
          color={255,255,255}),
        Line(
          points={{66,50},{10,-58}},
          smooth=Smooth.None,
          color={255,255,255}),
        Polygon(
          points={{-26,24},{38,-6},{64,58},{14,88},{-26,24}},
          lineColor={0,0,0},
          smooth=Smooth.None,
          fillPattern=FillPattern.Solid,
          fillColor={95,95,95},
          lineThickness=0.5),
        Line(
          points={{-20,36},{38,4},{42,14},{-10,42},{-4,52},{46,24},{50,32},{0,60},{4,68},{52,40},{56,48},{8,76},{12,82},{92,34}},
          color={255,255,255},
          smooth=Smooth.None),
        Line(
          points={{68,54},{72,46},{64,46}},
          color={0,0,0},
          smooth=Smooth.None),
        Line(
          points={{-28,46},{-24,38},{-32,38}},
          color={0,0,0},
          smooth=Smooth.None),
        Line(
          points={{78,42},{62,52}},
          color={0,0,0},
          smooth=Smooth.None),
        Bitmap(
          extent={{-84,-48},{-36,26}},
          imageSource="iVBORw0KGgoAAAANSUhEUgAAAqMAAAPCCAYAAAE7R+G1AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAFxEAABcRAcom8z8AAG3KSURBVHhe7d0JfFTV+f/xyR6yk50kJGELS9hBBEWKigiKCIIUBBEEqWvdF1xxqUvdt1K1ir/a1rba2ta22lq11ba2WrUudW3RatXibtX+2p//9vzPc5J7mOQeIHdyc3OTfM7r9X6RmQzJ5NznfueZu00ipmOOtqnVg9ormmr995HW++R7q7Ryrc+NxzR12bRp6t/r1nWb++bNk4XiKdBiPxZrzj+mpyjPzZXJvsv8Nd00nE+st8lMT5eJrm75k8Mfd326dq3zF/cleh5Ep0bBR2vWOH84zAQ/3zJNHRsbXD8Ebnq+tl+9rv+EjtHT5+8oXA9EMHoaP2iZTT1cD0BqWqc0cZLrm0jN+okTzcQ6v4nU3DVnDpMattdauwH1AyY2FDKXn3qTKl8I1wPRMZlJ89hmUlvvcP4nuN0xe3ab+Wudw7Z3JH3D+UPQQrZqueZNbHNSkzHBLWSb8Evt5salQ5OarEH77cKFzl/aGwWdHxF4UttrbSGcT6inkb/j7Na/qzM6PanbskWTn12Vl+f8A7rL/MZG87y+0fo8u0KXTWoQ92pLNXku7TUUFqoZNTWW3HY9bjftBs3186Omn4/7G0gdk9oFmNQuYCb140QaQmQm9R9pGQiRmdQP0zIRIjOp76dlIURmUt9Lz0GIzKS+k56LEJlJ3ZLeDyEyk/r3jHyEyEzqmxkFCJGZ1L9lFCFEZlJfzyxGiMyk/jWzBCEyk/pKZilCZCZ1c1YZQmQm9c9ZFQiRmdSXsioRIjOpL2ZXIURmUp/PHoAQmUn9U3YNQmQm9dmcWoTITOrTOQMRIjOpf8ypR4jMpD6Z24gQmUl9PHcQQmQm9ff9hiJEZlJ/kzcCITKT+qu8ZoTITOr9+WMRIjOpPyuYgBCZSf1J4U4IkZnUHxZNRYjMpH6veFeEyEzqd4pnIERmUr9ZsgdCZCb1f/rvhRCZSb25dC5CZCb1hrJ5CJGZ1OvL90eIzKReXb4IITKTennFEoTITOollcsQIjOpX6pagRCZST23ehVCZCb1rAFrECIzqesHrEOIzKSeUnMkQmQm9fjaYxAiM6nH1B2PEJlJPWLgSQiRmdTD6k9FiMykrq4/HSEyk3pww9kIkZnUgxrPRYjMpB446AKEyEzqAYMvQojMpO435FKEyEzqPkOuQIjMpM4eeg1CZCZ1j2HXI0RmUmc0fRUhMpM6bfjXECIzqVNGbEKIzKROHPl1hMhM6tiR30SIzKSOGvUdhMhMalPznQiRmdTBo+9CiMyk1o+5GyEyk1oz5qcIkZnUyrE/Q4jMpJaOux8hMpNaNP6XCJGZ1LwJDyNEZlKzJz6CEJlJTZ/4KEJkJjVtp8cRopZK3eVJhMhMaubMpxEiM6lZez2LEJlJzdn3eYTITGrughcRIjOpeUv+jBCZSS1YvhkhMpNauPqvCJGZ1OJ1f0OIZFJPKjnqTYVw5E4+zkxqovT4LQrhMBPqjbJT3lHonEQi7ZPW6dw6Ks58XyE1evpKWmbRPa6sOvdDhY7R89V2ld/BqK7+0geq+qKP4aDn5/WWaUp9PFxz2aeqr9PzEKgqgw5Ve82/er20HPN5fSNa/uTox+GaGrjx/3qsrOrhMoEPm7+mB4xXNFV26C2q/ub/dJsB5z3lrb6iTutTI1dbpW3SHtTMQkkit+V++f5pWqPG2MGQSdqgJU/qO1r7CZXHzNT61JinqYbCQvXe6tXq3+vWdZuVTU1elV8pTyzuQx0zZozzD+kJfrtwoTfZ3TKuPaK52fnEepPXVpirn3XZJDt/aV+yfuJEmdzylulIbTh/MNap2QNbPrSrQ2N+Y6Pzh8Ctddqcw/kfsGP71Ld8IpodVGU4WqeTygzLllWrVML1DaSOCQ0Zq3zIEp8yoaGRuTQTKppLS50PQsd482gn1ON6MLZtt3bz55tQj2yBcf0AtDjPMWdimxPq2V1z/cC+SF7AXXOUbIcT2l5f6goOGDxY3dzu79+RwBPa3hCtN7x1vWP27A5V4I50ekK35XBNnuAFU6Y4/4Du8MD8+eY5NbU+x67QZRMaxOlagyZ/bHuyP2pGTY0hXwvfY7QV2nOa6+dHKRYT2pswoSFjQkOW+DiRphCexD/SMhTCk/gwLVMhPIn307IUwpN4Lz1HITyJd9JzFcKT2JLeTyE8ib9n5CuEJ/FmRoFCeBJ/yyhSCE/i9cxihfAk/ppZohCexCuZpQrhSWzOKlMIT+LPWRUK4Um8lFWpEJ7Ei9lVCuFJPJ89QCE8iT9l1yiEJ/FsTq1CeBJP5wxUCE/ijzn1CuFJPJnbqBCexOO5gxTCk/h9v6EK4Un8Jm+EQngSv8prVghP4v78sQrhSfysYIJCeBI/KdxJITyJHxZNVQhP4nvFuyqEJ/Gd4hkK4Ul8s2QPhfAk/qf/XgrhSdxcOlchPIkbyuYphCdxffn+CuFJXF2+SCE8icsrliiEJ3FJ5TKF8CS+VLVCITyJc6tXKYQncdaANQrhSawfsE4hPIlTao5UCE/i+NpjFMKTOKbueIXwJI4YeJJCeBKH1Z+qEJ7E6vrTFcKTOLjhbIXwJA5qPFchPIkDB12gEJ7EAYMvUghPYr8hlyqEJ7HPkCsUwpOYPfQahfAk9hh2vUJ4EjOavqoQnsS04V9TCE9iyohNCuFJTBz5dYXwJMaO/KZCeBKjRn1HITyJpuY7FcKTGDz6LoXwJOrH3K0QnkTNmJ8qhCdROfZnCuFJlI67XyE8iaLxv1QITyJvwsMK4UlkT3xEITyJ9ImPKoQnkbbT4wrhSaTv8qRCeBKZM59WCE8ia69nFcKTyNn3eYXwJHIXvKgQnkTekj8rhCdRsHyzQngShav/qhCeRPG6vymEJ1Fy1JsK4UnIJ7eWHr8FIeh/tM5QGTkjF6qyU95BJ5nJTBqq4sz3kYLcMUt8k2lHvwkHqapzP0QHtU5bh4aqvuhjOOSOXhBoIl1D1Vz2aZ9WNO9CmcShLdMR7ritcO/1qvaaf/VqNZe+KxPY6UpMdaiifc9SAzf+X49Ufc4z3uQVmL8mxmOFprIbJ6v6m//TrQr3OMqbtE3yxPrSmKlt0B5s9YrmTYZ8LeR+mRh5LCPi0agdpz2seQvGaCgsVCubmtRNM2eqzcuXq3+vWxcrD8yfr86cNEnNqKlp87xbfaxJUc3SGN08VmmfaWpIUZG6a84c5wJFx3y6dq06ZsyY5GK/WyvRGO2GvKSYSbpj9mznZCI+5jc2Jhd0rxkLNLPGuv5o9C4frVnjFfFbsvDjNm7LTE93PnFA3D5rllfAuaZiunhskDcaricCBPHe6tVe4XZ65Jbl5jp/CRAmeTOn603eHHds5GZkOH8QEBVdhve1VGO7MbykxPkfgO6iy/KmlurUQ96duR4EdDddnqZ3fcf1TSAOtqxaZYrU+U0gDrwkVZ9qslnA9SCgu3i1aYtU/FijWNHdkmvSV6TtvuH8AUBXaC4tVa+1q8GkWnR/I9lHGkWLMF07fboaklRj29OhInU5W6Nw0RGXTZtmasVVRx2RcpFuy3ma/EyO++x75NiOsOtJhF6kO7KfJr9Tjoh3/aGIp0cXLTLLTdyruZZtV4m8SDvqas2bFDnoNo6nd/R00hfKsRoyx3tp23rj0t1iW6SdIZvSFmpekYvy3Fx16IgR5kyAnryZ7YnFi02P1/68pwbtdG2z5pqTnkz/fe5vAHFBkSL2KFLEninSTxJpQGyZIv04kQ7ElinSj9IygNgyRfpBWhYQW6ZI30vLBmLLFOm76TlAbJkifTu9HxBbpkj/np4HxJYp0rcyCoDYMkX6RkYhEFumSF/PKAJiyxTpa5klQGyZIn01sz8QW6ZIN2eWArFlivQvWeVAbJkifTmrAogtU6QvZVUBsWWK9IXsaiC2TJE+lz0AiC1TpM9m1wKxZYr0mZw6ILZMkT6VMxCILVOkT+Y0ALFlivSJ3EYgtkyRPpY7BIgtU6SP9GsCYssU6cN5I4HYMkX6YP5oILZMkd5XMB6ILVOk9xRMAmLLFOndhVOA2DJFelfRLkBsmSK9o3g3ILZMkd5eMhOILVOkt/WfBcSWKdJNpXsDsWWK9KbSfYDYMkW6sWw+EFumSK8tXwjElinSKysWA7FlivTSys8DsWWK9KKq5UBsmSI9v2olEFumSM+pXg3ElinSMwYcBsSWKdJTaw4HYssU6Ym1RwOxZYr02LpjgdgyRXpU3QlAbJkiPXzgyUBsmSJdU78eiC1TpKsazgRiyxTp8sZzgNgyRbp00HlAbJkiXTzoQiC2TJHuP/gSILZMkc4bcjkQW6ZI9x56FRBbpkhnDbsWiC1TpDObNgKxZYp0etONQGyZIp06/GYgtkyRTh5xKxBbpkjHj/wGEFumSEePuh2ILVOkI5q/C8SWKdKhzd8HYssUaePoHwKxZYq0bsxPgNgyRVo99l4gtkyRlo+7D4gtU6Ql4x8AYssUacH4h4DYMkWaO+E3QGyZIs2c+DsgtkyRJiY9BsSXFGna1CeA2DJFmjHjKSC2TJFm7fkMEFumSLPnPAfElinS3PkvALFlirTfopeB2DJFmr/0L0BsmSItWPkqEFumSIvWvAbElhTpByVHvKGAOCpe+5Ip0kT/o19X/b/4FhA7ujxbilRGZvV4VXbS20Bs6LK8vaU624207HxVvv5doNvoMny4pRp3PEoySupV5TkfAF1O19vWl/VOjCszB4xRVRd8BHTOee+FVpQdGXdLezDgkk8Ap9K1d3sFWWAqJkZjlaYK9z5D1V75T/R2l/9DpWXmSiF+bJZ+LxkLNLOGVRz/gKq77t+IsfxdDvXSsMNvaPraOE4zk5TdMElVnfZrVX/jZ+iE4n1P94rOK7xGjdGNY4S2QXtZS144KmfIVFW835mq6tQHVMOm/8ZO7aWbVdmaW1T+tBUqo39dm+fe6g5thcbo46Ncm6lJny3FvqnVg60e0V5p5RXPO0n3eY+7TfP+r/ycORoJxjBDCkwKQ5r65BRSM2pq1JmTJqkH5s9X/163LlZeW7FCbdp9d7WyqUk1FBa2ed6t5GX6JI1Cj/GQTRpXanbBHTRsmLpv3jznQu8LPlqzRl02bZoaUlSUXMxPavJGldFFQwrxLs1M+BHNzWZBuBYQOubuuXPV8JISr4A/06SNYXRwmGIsyc5WDy1Y4JxgdK1jxozxilcs1fr0MAU5v7HROVmIj7vmzEku3FlarxzVmvkjNy9f7pwI9CxJibtR67HjdU29t3q1849E73Ly+PFe0S6WhR/XIdsSzZN1/RHoW6QWtPukMLp7ZGpmW57riQIiNyNDClb2jEU6npGN4K4nBGyLbDrUtSNKTBV10VBbVq1yPgEgiNbttLIjJrTh/EVAZ8kuX11fF7WUWWrjs0/XrnX+cCBMVf36SbEGOnI/l54T3UHXntjhuMP1n4Go5GdlbbdQ33L9JyBqBwwe7CzUS10PBrrLpIqKtoUqB9i6Hgh0J12atlCdDwC6m2xdMhW6btQo5wOAONAlen7ijZUrnd8E4kAX6QcJDhBBnOkiNS/5zm8CcWCK9E2KFDHVmqIq8WnrF64HAd1FDu3zatMUKYWKuPlGUl3aIqVQEQdyXty329VkmyIVOZrrPwNdTXaFtq9HZ5EKeTMll2px/SCgK0gxumpxm0Xq2Uu7aeZM5w8FwrCt4vTssEg9YzW5EJbrlwCpkOL7KKnGtqXDReq5UCvOznb+UmBHHl20aIfJ2V7gIk0m//mCKVOcTwZIJrVyelLtBNGpIvW8plGwaC8zPV3tklQnqQqlSNvL1Grz851PHL2XXPdUCurspFoIQ5cUabJbNfklXOKx9/H6y4bWZd1VurxI27tXM79Ukz/S9ccjng4dMcIst7maa9l2lciL1EVeHrzCvX3WLOcEIVryyifLo1aT9xyu5RaVWBSpi0yM7EiQJyhXZbt2+nTnZCJ1ckFjrxjF1ZprWXS32Bbp9sjBB6M0b3JlouP4ETdxcPHUqaoqL8/O1eGa7PJ2zWtc9cgi3ZHNmrQQ0tB7C0fIpYNkr1lP7oXlCCG5hr2cPJlcfGKh9gPNNSc9mfn7XN/oa57TbtBWaLtp7Qt8W+RDwDyyErTnfc/1f13k9x6oyYZveZPpeq59jZkb1zeAuKBIEXsUKWKPIkXsUaSIPYoUsWeK9JNEmgLiyhTpx/oLIK5aizRd3wDiyRTpP9IyFBBXpkg/0l8AcWWK9MO0TAXElSnSD9KyFBBXpkjf118AcWWK9L20bAXEVUuRpucoIK5Mkb6rvwDiyhTpO+m5CogrU6Rvp/dTQFyZIt2ivwDiyhTp39PzFBBXLUWaka+AuDJF+lZGgQLiyhTpm/oLIK5Mkb6RUaiAuDJF+reMIgXElSnS1/UXQFy1FGlmsQLiyhTpa5klCogrU6R/1V8AcWWK9NXM/gqIK1Okr2SWKiCuTJFu1l8AcdVSpFllCogrU6R/ySpXQFyZIv1zVoUC4soU6cv6CyCuTJG+lFWpgLhqLdIqfQOIJ1OkL2ZXKSCuTJG+kF2tgLgyRfp89gAFxJUp0uf0F0BcmSL9U3aNAuLKFOmz2bUKiKuWIs3RN4CYMkX6TE6dAuLKFOnTOQMVEFemSJ/SXwBxZYr0jzn1CogrU6RP5jQoIK5aijS3UQFxZYr0Cf0FEFemSB/PHaSAuDJF+ljuEAXElSnS3/cbqoC4MkX6SL8mBcSVKdLf5I1QQFyZIn04b6QC4soU6a/ymhUQV6ZIH8wfrYC4MkV6f/5YBcSVKdL7CsYrIK5Mkf6sYIIC4soU6T0FkxQQV6ZIf1K4kwLiyhTp3YVTFBBXpkh/WDRVAXFlivSuol0UEFemSL9XvKsC4soU6R3FuykgrkyRfqd4hgLiyhTp7SUzFRBXpki/WbKHAuLKFOlt/WcpIK5Mkf5P/70UEFemSDeV7q2AuDJFenPpXAXElSnSm0r3UUBcmSK9oWyeAuLKFOnGsvkKiCtTpNeX76+AuDJFem35QgXElSnSq8sXKSCuTJFeWbFYAXFlivTyiiUKiCtTpJdWfl4BcWWK9JLKZQqIK1OkF1UtV0BcmSL9UtUKBcSVKdLzq1YqIK5MkZ5bvUoBcWWK9Jzq1QqIK1OkZw1Yo4C4MkV6xoDDFBBXpkjXD1ingLgyRXpqzeEKiCtTpKfUHKmAuDJFemLt0QqIK1Okx9ceo4C4MkV6bN2xCogrU6TH1B2vgLgyRXpU3QkKiCtTpEcMPEkBcWWK9PCBJysgrkyRHlZ/qgLiyhTpmvr1CogrU6Sr609XQFyZIl3VcKYC4soU6cENZysgrkyRLm88RwFxZYr0oMZzFRBXpkiXDjpPAXFlivTAQRcoIK5MkS4edKEC4soU6QGDL1JAXJki3X/wJQqIK1Ok+w25VAFxZYp03pDLFRBXpkj3GXKFAuLKFOneQ69SQFyZIp099BoFxJUp0lnDrlVAXJki3WPY9QqIK1OkM5s2KiCuTJHOaPqqAuLKFOn0phsVEFemSKcN/5oC4soU6dThNysgrkyRThmxSQFxZYp08ohbFRBXpkgnjvy6AuLKFOn4kd9QQFyZIh078psKiCtTpKNH3a6AuDJFOmrUdxQQV6ZIRzR/VwFxZYq0qflOBcSVKdKhzd9XQFyZIh08+i4FxJUp0sbRP1RAXJkirR9ztwLiyhRp3ZifKCCuTJHWjPmpAuLKFGn12HsVEFemSCvH/kwBcWWKtHzcfQqIK1OkpePuV0BcmSItGf+AAuLKFGnR+F8qIK5MkRaMf0gBcWWKNG/CwwqIK1OkuRN+o4C4MkWaPfERBcSVKdLMib9TQFyZIk2f+KgC4soUaWLSYwqILSnStJ0eV0BctRTp1CcUEFctPekuTyogrkyRZsx4SgFxZYo0c+bTCogrU6RZez6jgLhqKdK9nlVAXJkizZ7znALiyhRpzr7PKyCuTJHmzn9BAXHVUqQLXlRAXJki7bfoZQXElSnSvCV/VkBcmSLNX/oXBcSVKdKC5ZsVEFctRbryVQXElSnSwtV/VUBcmSItWvOaAuLKFGnxur8pIK5aivTQ51XJEW8AsaSL9ONEzrjDVMlRbwKxpIv0Ii2h+n/xLSCWpEDN6H/486r0+C1ArOjS3FqkemwsO+ltBcRFZu3ObQq0daR9WHbKOwrobrnjV7kK1I77yte/q4DukpZTvN0C9UZBzvB9VcWZ7wOR0rXXoQJNHqrynA+ALpdROliKs7yl7FIbqurcD4HQ5U07QopzY0uZhTNU5YYtquqCj4BOyaqdIMW5qaWsuma8kjtqnqq+6GMgEF07otpUUUSjQFOlh96lBlzyCeCUlp0vhXmfqZhuHo2aKtrnPFVz2afo4xLpmVKYD5vKiPH4QJ5o7eX/ULVX/hO9XNG887yX8rVm6ffAMUJTaVm5qubSd1XtNf9CD1c490yvKG+XBdxbh7wUqLydDlJ11/0bMVZx/APey7dYLAuvr45c7UFNZVYMUdVnPakGbvw/RKx4/gavGMXRGqMDQzZXmOIVxfuerupv/AydUHXar1V2w6TkYjxOY3TRqNNkg7Cd8MI9jlLV5zyu6m/+T59VdugtKrtxcnIRvqKt0hgxHku1O7TkBacyiqtV/rQVqmzNLar20s2qYdN/Y6fq1AdU8f7nqJxh09s891Yvaxu00Rqjjw/ZBjxTO0mT5BbSgghJKY+rkLzveY8X8v+luCTd5OdKP85gMBzDW/lkZTlfu02TrS5vaa4VbpvKc3NVQ2GhmlFTo2YPHKhWNjWpMydNMm6aOdPnvnnz2nhowQL10rJlbbyxcqX697p1bch97R8n/7f9z9u0++6+3+k9H3lu8hzlucpzlufu+pt2QOboEU3mTOZOtg/LXMqcMhiMGA3ZByIhd60mAfeZ5lupa/PzTSgc0dysNs6YYYLEFUKIhy2rVpllJOEuy0yWnSxD17LVZJnLspejGaUWpCYYjD41pOjlrZYc/9NmBclMT1d71NaqC6ZMUQ/Mn+9c4YCOkq5cakk6bamt9vWmSQ1KLbIdiNGtQ06+kd0y8nbOFmhJdrZ5q3jXnDnq07VrnUUOxJnU7rpRo0wtJ9e2JrUuNd+pE88YvX9karJtyxyN5ZFXddnG9tGaNc7CA/oqaRZu23NPtU99fXLgisc0WZdknWL0oiF7GU/TPtDMwp5UUWEC0lUgAMIl65qsc97617ouyjrJEQAxGrIw5PAMswOmICvLbCOiiwR6BuluL5s2zay7sg63rstyqWSCNuQhEyp7K81E71xZqX67cKFzoQDoXZ5YvFjtWl3thay4SSNktzNkY7YcBKxyMzLMITyuiQUAIRkhWSGZock+jj63Q0w2SJsJ2DB5snOSACAVsnnPyxftcK1XjDma+aPkEAvXHw4AXenuuXOTj62dp8V+XKmp+Y2Nzj8IAOJAMkqyqjWzun1IupsNwq4nCwA9gZxlKFmmRXalSLlIgzklzfWEAKAne3TRIi9U75LAC3PIdeg49AhAnyKHYEn2aZ26WOrzQ4qKnL8AAPqS4SUlEqivt0Rjx8bzbPcEAL/WHVXPt0Sle8hBrc7/DADYSrJS813Ie0FVXp7zPwAA/GTTp87ONttPnQ8EAGybZKdmLh94txz973oQAGDb5GNjdIbKtUIS5kPEXA8CAGybZKdkqAlSuQCr60EAgG1LOisqoYo1aVFdDwQA+MlZULktIdoSpJ9q9YnEf+Vzv13/AQCwlVzdv6o1O9sEqXiu9U7XfwQAtOypf7I1M51B6rlEI1ABYCvJRMnG9nm5zSD1bNbk+zfNnOn8wQDQm90xe7bJwOQOtL0dBmmyAzV5rGxgdf1CAOgNnl6yxGTdfq3ZtyOBgjTZeZr8v2PGjHE+EQDoSdZPnGgy7dTWjAsi5SBtb4gmP4dNAAB6gk27724yS7LrI82Vax0VWpC2t5cmP3ef+nrnHwEAUTpg8GCTSbtonQ3O9rosSNuTw6rkmCv5XfIHfbp2rfOPBYDOOmjYMJM1Zdr2dhKFJbIgdXlP83ZgyYf937bnns5JAQAX2aMu2SEZIjuGJFNcWdPVujVIt2WLtlRrfXLm1WXLqlXOiQTQu723erVa2dRk82ChJhnhyo7u0vrc3N+Mo4e1KZo3qbMHDuRwLKCHk8ONZH+Kt17LOv6g5sqAOGp93u5v9kQ3a6M0b4HIVa3YZAB0r9tnzVI7V1ba9bJJu0FzrcM9Uevf5f5mbyTbUOQUr1rNW6iyjeWI5mY+bhoISN4NyrrjbacUslP5Qq27tld2h9a/3f3NvkwOj7hVkw3YXoGI8txcUzh8ogB6q3v23dfUuHyGW3Ltz9VknehLAdlRrXPk/iY6ToL3Tm2tltztCnm1lm25F0+dSteLyEi3KDUn2x6TO0YhXaPU6re1sI+p7Ita59X9TURDjrGVV/qjteQdaclKsrPVjJoadfL48eaMjOeWLnWuPOj55KMrZLu+LGtZ5vIuyFUTE7XDNakdqSFXbSEarcvE/U30TC9p92qXa7KiyVlmsnE/6Ure29RQWGhWXjncRC7yLaf8SnDLpydIePelz/aSv1XI3y5zIHMhcyJzI3Mkc+Waw2SZmsy9LAPpAGWZyLKRZeRaduiZWpe3+5tAV5NOqj0Jmo5w/V/X7wC6GkEKAJ1EkAJAJxGkANBJBCkAdBJBCgCdZIP0EwBASpKCNA0AkAIbpB8n0gEAKbBB+o+0dABACmyQfpSWAQBIgQ3SD9MyAQApIEgBoJNskH6QlgUASIEN0vfTsgEAKbBB+l56NgAgBTZI303PAQCkwAbpO+m5AIAUEKQA0Ek2SN9O7wcASIEN0i3peQCAFNgg/XtGPgAgBTZI39I3AADB2SB9M6MAAJCCpCAtBACkwAbpG/oGACA4G6R/yygCAKTABunrmcUAgBTYIH1N3wAABGeD9K+ZJQCAFCQFaX8AQApskL6qbwAAgrNB+kpmKQAgBTZIN2eVAQBSYIP0L/oGACA4G6R/zioHAKTABunLWRUAgBQkBWklACAFNkhf0jcAAMHZIH0xuwoAkAIbpC9kVwMAUmCD9Hl9AwAQXFKQDgAApMAG6XPZNQCAFNgg/ZO+AQAIzgbpszm1AIAU2CB9JqcOAJACG6RP6xsAgOCSgnQgACAFNkifyqkHAKTABukfcxoAACmwQfpkbgMAIAU2SJ/IbQQApMAG6eO5gwAAKbBB+ofcwQCAFNggfbTfEABACmyQ/q7fMABACmyQ/rZfEwAgBTZIf503AgCQAhukD+WNAgCkwAbpL/ObAQApsEH6QP4YAEAKbJD+omAcACAFNkh/XjAeAJACG6T3FkwEAKTABulPCycDAFJgg/THhVMAACmwQfqjop0BACmwQfqDomkAgBTYIP1+0a4AgBTYIL2zeDoAIAU2SL9bPAMAkAIbpN8umQkASIEN0m+V7A4ASIEN0m+U7AkASIEN0q/3nwUASIEN0lv7zwYApMAG6S2lcwAAKbBB+rXSuQCAFNggvbFsXwBACmyQfrVsPwBACmyQfqVsPgAgBTZIrytfAABIgQ3Sa8oPAACkwAbpVRWLAAApsEF6RcWBAIAU2CC9rOLzAIAU2CD9cuVSAEAKbJBeXHkQACAFNkgvrFoBAEiBDdILqg4GAKTABul51YcAAFJgg3RD9WoAQApskJ5dfSgAIAU2SM8asBYAkAIbpKcPWAcASIEN0tNqvgAASIEN0lNqjgAApMAG6Um1RwEAUmCD9ITaowEAKbBBelztFwEAKbBBemzdsQCAFNggPbrueABACmyQHjnwRABACmyQHj7wJABACmyQfmHgKQCAFNggXVt/GgAgBTZID60/HQCQAhukqxvOAACkwAbpyoazAAApsEG6ovEcAEAKbJAub9wAAEiBDdJljecBAFJgg3TJoAsAACmwQbp40JcAACmwQbpo8EUAgBTYIF04+GIAQApskM4f/GUAQApskO435DIAQApskO475HIAQApskM4ZeiUAIAU2SGcPvRoAkAIbpHsNuwYAkAIbpHsOuw4AkAIbpDOHfQUAkAIbpJ9r2ggASIEN0t2abgAApMAG6a7DbwIApMAG6bThXwMApMAG6c7DbwEApMAG6U4jbgUApMAG6cQRXwcApMAG6YSRtwEAUmCDdNzIbwIAUmCDdMzIbwEAUmCDtHnUtwEAKbBBOnLUdwEAKbBBOrz5DgBACmyQDmv+HgAgBTZIh4y+CwCQAhukg0b/AACQAhukDaN/BABIgQ3SgWPuBgCkwAZp7ZifAABSYIN0wNh7AAApsEFaNfZeAEAKbJBWjPs5ACAFNkjLxv0CAJACG6T9x90PAEiBDdLi8Q8CAFJgg7Rw/K8AACmwQZo/4WEAQApskPab8GsAQApskOZM+C0AIAU2SLMm/g4AkAIbpBkTfw8ASIEN0rRJjwEAUmCDNDH5DwCAVNiOdOcnAAApsEGaPu1JAEAKtgbp9D8CAFJggzTjc08BAFJggzRz92cAACmwQZo161kAQApskGbP/hMAIAU2SHP2eQ4AkIKtQTrvBQBACmyQ5u7/IgAgBTZI+x3wEgAgBTZI8w58GQCQgq1B+vm/AABSYIM0/6DNAIAU2CAtOPgVAEAKbJAWHvIqACAFNkiLDn0NAJCCrUG69nUAQApskBYf/jcAQAq8IL2nYP63VcmRbwAAAijY/04J0QclSGWo/se8BQAIQLJTyzQpqseqjJJBqvS4vwMAOiCjYrSE6HEtEbp11Gmq9IQtAIDtkKzUhkpwbmOkvZA9ZLYqO/ltAECS7OH7SYC+1ZKVHRtvZZQNU+WnvQsAfVpm9fjAAdp+HK6p/ut+rSrOeA8A+oTSo+1n1vu2g3Z23K2p0iN+ryrOeh8AepXSY+zn1NtDmrp6rNJUTtPeqnLDBwDQI+WM2t8Lz7USbN09Nmmq34SDVNV5HwJALElGSVa1Zlbsx2JNJdIzVdkR96vqC/8BAJEqO+pXKi0zxwvOFRJMvWGcpJk/qmj+ZWrAxR8DQCiKF13nBaY4TetTQ04EeFJTaTn5qmT5rWrApZ8AgFP/Q25X6fllXmA+r23vwPg+Pwq02zQzYTkj9lKVpz+jaq74J4BerurM51XuqLleWIrbtXKNEeKQkL1SM5OcUVSlSg68RtVe9b8AeoiSpV9RGSW1yWG5USvRGDEZsjAu0v5XMwspZ/gequyw76q6a/8FoIuVf+H7uqOcnRySsi7KOklQ9rIhXa2csfCMZhd4vwkHqLIv3KHqvvJvAO2UH3GXWUeS1xlN1iHZkUxIMrY7RmgbtDahm1nWoAr3/KKqOvXXauANnwE9jtRu4ewTTC0n17YmtS41P1pjMLptTNXO1x7T2hRpekG5ypu0SJWuuF4NOP9ZVX/T/wNSJjUktZS30+dNbbWvN02OipG31VKTDEafGlL08nZJzr6QQzxcK4jKrByq8iYvUsX7n63KD/u6qjn/KdVwy38QYzVf+pMq/8K3zDKTZSfL0LVsW8myl6NXpBamawwGIyZDjt2dqcn1EuTtm4S1XKThFc21Mm9TWkamyixvVLkjZhoF01ep4rknqZIF56jytbdY1ac94FN32Wafxlv/2yGu/+v6HcnPQZ5T8b6nmefoPV957mlZuc6/bQdkrmTOZO5kDmUuZU4bNQaDwQg8JDxkW5oXzl5A36RJ0CST8GlPQqm9bYVXe66f1/53yvOQ5yMXpfACb7xG6DEYjJRGaN2oaCgsVM2lpWpGTY1a2dRknDlpkto4Y4a6aebMNu6bN8/npWXLfP69bp2P63Gun9f+d8rzkOdz6IgR5rnJ8xxXVmaet+vv6QAvvGXe6EQZjB4+pKOSlVh2aMl1YncYhFV5eWrX6mp10LBhav3EiTbcJJRc4YW2vPCWeZNwlmCW+azNz3fOdzuyfGQ5yfKS5TZZs58+yWAwwhlyXOss7UztDm2bwSgdoIShrMy3z5qlnlu61LniIx4kgO+YPdssL1lusvxcy7WVLHdZ/tLtSj1IXTAYDD1k++HR2l2afO5Lm5UnMz3dvOU8efx4tWn33QnGPkoC97Y99zR1IPWQm5HRpk5avaNJHcnJJBzjyeg1Q96ezdPkPGFfFzmkqMhsn5MVhLfQ6IzNy5ebOlo3apSpq/a1pr2uSR0u0HI1BiNWQ7ZnyQHNvuM5Zw8cqC6bNk09vWSJs/iBKEj9XbXrrmqf+nrzDqddnUrdXqpxQD6jy4fseZVXc3nrZItw58pKdfHUqbzdRo8kdSv1K3WcXNfaB5rU+xyNwQg0ZJuS7DVt01nK9qhrp09XW1atchYj0JtIncuRB3vUtrmEnZBNU/LOi22vDDPk0KBrtY81UyTlubnq+LFj1aOLFjmLC+jLnli82Kwfsp5464wml76T9UjWJ0YvHnJoiHw2i307Lsf0bZg82WyYdxUMgB17Y+VKsx61O0ZWNgfI4XlcLq8HD9lQLod9mIUqG9SPaG5mJw8QAdnWesyYMe0PyZITDLiQSozHUs18IJ6QU/rksA/XAgYQPTkRRNZLbx1tXV9lvWV005C95Y9oZoHI4UQPLVjgXHgA4kfW1/mNjcmhKuuzrNeMLhqyTVOuxGMmXF7R7p4717lwAPQ8sj6361Tl4i6c5trJIWf82LN9ZOO1a/IB9D6yviedHCBnXckZV4wODLneo/nkzuElJeqB+fOdEwyg75AcSOpSP2vNCUbSkAkxEyTbNl9bscI5kQAgh1S125YqF17pk0PeqpuD3OWc3o/WrHFOGABsi+RGUqDKO9he/5ZfNhKbPeryVp2rFwEIi5w0k/SWXz5tt1cd6C/XzTR/nFwb0zUBABAWOUbcyxxNPi21xw45Q8G8Xf907VrnHwsAXSnp7f59Eko9YUgLLefNmmtpuv4oAIiaXFNVckmTfTHVWuyGPClzaBJXQAIQV5JPklOteRWLMJWdRWYvO+EJoKeQi6RkpqV5YdptO6HMhYs5Zx1AT5XUmb4soRbVkCtbm20MricFAD2NXMlfck2TC0x32SjXzLFYricBAD1d0udN1UnohTnkQ6v4QDYAvZ6cCCR5p8mVpDo/0hKJTxoKC52/DAB6q+bSUiX51xqFKQ3Z887xngD6rKRtpYGvbTpC4zOJAPR5SW/vJRc7NEyAvrd6tfMHAkBfI6euSy625uN2hxx0SoACQDtJQbrdM524KDIAbIM0mJKTLXHpH2+xEwkAtk8u6anzUi601GYsKMvNdf4HAEBbtfn5EqSrWuKzZfARHQDQQUnbR82YI6nqeiAAwG1IUZGE6GIJ0Vd+u3Ch80EAADc5DV7n5zsSos4HAAC2T/KTEAWAFBGiANAJhCgAdAIhCgCdQIgCQCfYEL12+nTnAwAAbq2nf7aEqHA9CADg5mWnCdEq7b5585wPBAC0JR+1XJwcou+13nA9GADQluTlm625aUL0U+1sjQ+kA4Dtk4+NP7o1N9uEqNDt6X+PGTPG+R8BoK87c9Ikla9z0stMX4iKTI2LMwNAW/LJn5KPyXnpDFHvG+snTnT+IADoay6YMsXkoisrnSEqpGWdUVPj/IEA0FfsU1/f5i18su2GqGjSCrKynD8YAHq74uxsk4OufBQ7DFFxtSaPeWLxYucvAYDe5qVly0zuXdKag9vSoRAVWzR53M6Vlc5fCAC9hWzGlLyT40BdeZiswyHqWavJ4zm7CUBv89CCBSbfVrTmXUcEDlHxkZajZaanqy2rVjmfDAD0FJJjuRkZJtfk7E1X7m1LSiHqeUyT/ytnOcnHh7qeHADEWesndqpHWnMtqE6FqOcGTX6GPBnCFEDcSU7JqZuSW5JfrlzrqFBC1HOr5oUpb/MBxM1Ha9bYzrOz4ekJNUQ9d2qtP1jds+++zj8GAKLywPz5KjMtzWTStzVXbqWqNevc3+wsOTygQZOfv27UKOcfBwBd5YjmZpM/tdprmiunOqtLQzTZiZr8HtkDdvfcuc4/GAA6Sw6/lJyRvDm2NX+6UmQh6nlJ87pT2bC7efly50QAQEe9tmKFmlRRYXJFus7nNFf+dIXIQzSZbJuQ47Lk989vbFTvrV7tnCAAaE/yYsmQISY/JEe+oblypqt1a4gmk/Pz5Tp98lx2ra5Wzy1d6pw4AH2X5ILkg+SE5MWOzmuPQmxCNJm8ouRr8rzKc3PVbXvu6ZxQAL3f7bNmqaq8PJMHkgs3a67c6C6xDNFkclbULlrrEzV7+XnbD/Resn57e9XFFO1hzZUPcdD6PN3fjCP5MD3vbb9c5/TiqVOdCwJAzyEfRyTrs6zXsn6frrnW/zjqcSGabLO2Smv9I0zLLwuDU0+B+JL1U9ZT7y26kKsmyfrsWs/jrvVvcH+zp5HDGrxL9Qm5ypR8cik7qYDuI4cxynoo66O3bkrz87TmWo97mta/yf3Nnk4uaXWeVqZ5C6+5tFRdteuudKtAF9k4Y4ZZz7x1TtY/2QwnF3Z3rac9Xevf6f5mb/SgtlDzFrCQg3RlwcvFCVxFAcBPGhFZb7yD3D37afdprvWvN2r9u93f7Cvkgimy4L0iEHKNVPnIaD5XClinnl6yRJ05aZK9ApJH1htZf1zrVV/ROhfub/ZlcmiVnO/vnaLqkc9ekY3icpqZq9iAnkzqWjZ37VFb26buZT2Q89BTvXBxb9Y6R+5vwk82BxyttQ9X2QZ0/NixXPoPPYLUqdRr8rZLUaVJfd+rueoffq1z5/4mOu5JTU5B213zCtIzvKTEHDwsZ15wsWpEQersjtmzTd21D0ohdXqhJu+4XPWMjmudU/c3EQ55CyQFO1fL1bxC9siGeSl2Ob1VPuvatVIAyaROpF7k0KH2O3aE1NlemtRdnM/26Q1a59z9TURD9mRKsctRA/J2ylsRkkk3u7KpyWyPleslcupr7yTLVZavLGdZ3q4uUkidyE4dOYSvL+0Jj6PWZeL+JuJDuln5TJjDNbmWgKuj9cge1AMGDzZ7U2+aOdOslHS43UPmXeZfloMsD7l0m7wgupabkFMeZfnKSSOyvNmRE3+ty879TfRMsp1LrnQj5x/L6XS7ae13hG2LBLDsmZULvVwwZYoNYS+I+8qxtPJ3egHohaDMh8zL7IEDzTwln4GzLTLvMv+yHGR5yHJhO2Tv0rqs3d9E3/KRJjvIfqDJ9V3lkBYvhL0g3l4HHJSEkByPm0zevsphZDsij2v/fzsSah0lHaEXgF4Iynxcrsn8yDzJGXGueUTf0loz7m8CXUlCW653kEy6NDm8Zkfkce3/r/w81+8BuhIhCgCdQIgCQCcQogDQCYQoAHQCIQoAnUCIAkAnEKIA0AmEKAB0AiEKAJ1AiAJAJxCiANAJNkQ/AQAElhSiaQCAgAhRAOgEG6If6xsAgGCSQjQdABAQIQoAnWBD9B9p6QCAgJJCNAMAEJAN0Y/0DQBAMIQoAHSCDdEP0zIBAAERogDQCYQoAHSCDdEP0rIAAAERogDQCTZE39c3AADBJIVoNgAgIBui7+kbAIBgtoZour4DABBIUojmAAACsiH6rr4BAAiGEAWATrAh+k56LgAgIEIUADqBEAWATrAh+nZ6PwBAQIQoAHSCDdEt+gYAIJikEM0DAARkQ/Tv+gYAIJitIZqRDwAIiBAFgE6wIfqWvgEACCYpRAsAAAHZEH1T3wAABEOIAkAnJIVoIQAgIBuib+gbAIBgCFEA6AQbon/LKAIABESIAkAn2BB9Xd8AAASzNUQziwEAARGiANAJNkRf0zcAAMEkhWgJACAgG6J/1TcAAMEQogDQCUkh2h8AEJAN0Vf1DQBAMIQoAHSCDdFXMksBAAERogDQCTZEN+sbAIBgtoZoVhkAICBCFAA6wYboX/QNAEAwSSFaDgAIyIbon/UNAEAwSSFaAQAIyIboy/oGACAYQhQAOiEpRCsBAAHZEH1J3wAABEOIAkAnJIVoFQAgIBuiL2ZXAQACIkQBoBNsiL6QXQ0ACIgQBYBOsCH6vL4BAAgmKUQHAAACIkQBoBNsiD6nbwAAgkkK0RoAQEA2RP+kbwAAgiFEAaATbIg+m10LAAhoa4jm6DsAAIEQogDQCTZEn8mpAwAERIgCQCfYEH1a3wAABJMUogMBAAERogDQCTZEn9I3AADBJIVoPQAgIBuif9Q3AADBJIVoAwAgIBuiT+obAIBgtoZorr4DABBIUog2AgACsiH6hL4BAAiGEAWATrAh+njuIABAQIQoAHSCDdE/5A4GAARkQ/Sx3CEAgIBsiD7abwgAICAbor/vNxQAEJAN0d/1GwYACMiG6CP9mgAAAdkQ/a2+AQAIxobob/JGAAACsiH6a30DABCMDdGH80YCAAKyIfpQ3igAQEA2RH+V1wwACMiG6C/zmwEAAdkQfTB/NAAgIBuiD+SPAQAEZEP0/vyxAICAbIj+omAcACAgG6L3FYwHAARkQ/Tn+gYAIBgboj8rmAAACMiG6L0FEwEAAdkQvadgEgAgIBuiPy2cDAAIyIboTwp3AgAEZEP0x4VTAAAB2RC9W98AAARjQ/RHRTsDAAKyIfrDoqkAgIBsiP6gaBoAICAboncV7QIACMiG6PeLdgUABGRD9HvFuwIAArIhemfxdABAQDZE7yjeDQAQkA3R7xbPAAAEZEP0O/oGACAYG6LfLpkJAAjIhujt+gYAIBgbot8q2R0AEJAN0W+W7AEACMiG6DdK9gQABGRD9Lb+swAAAdkQ/bq+AQAIxobo//TfCwAQkA3RW/vPBgAEZEN0U+neAICAbIjeUjoHABCQDdGbS+cCAAKyIfo1fQMAEIwN0ZtK9wEABGRD9MayfQEAAdkQvaFsHgAgIBuiXy3bDwAQkA3RjWXzAQAB2RD9ir4BAAjGhuj15fsDAAKyIXpd+QIAQEA2RK8tXwgACMiG6DXlBwAAArIhenX5IgBAQDZEr6pYBAAIyIbolRWLAQAB2RC9ouJAAEBANkQvr1gCAAjIhuhlFZ8HAARkQ/TSys8DAAKyIfrlyqUAgIBsiF5SuQwAEJAN0YsrDwIABGRD9KKq5QCAgGyIXli1AgAQkA3RL+kbAIBgbIheUHUwACAgG6LnV60EAARkQ/S86kMAAAHZED23ehUAICAbohuqVwMAArIheo6+AQAIxobo2dWHAgACsiF61oA1AICAkkJ0LQAgIBuiZww4DAAQkA3R0wesAwAEZEN0vb4BAAjGhuhpNV8AAARkQ/TUmsMBAAHZED2l5ggAQEBJIXokACAgG6In1R4FAAjIhuiJtUcDAAKyIXqCvgEACMaG6PG1xwAAArIhelztFwEAAdkQPbbuWABAQIQoAHSCDdFj6o4HAARkQ/RofQMAEIwN0aPqTgAABGRD9MiBJwIAArIhesTAkwAAAdkQPVzfAAAEkxSiJwMAArIh+oWBpwAAArIhelj9qQCAgGyIrq0/DQAQkA3RNfXrAQAB2RA9tP50AEBANkRX6xsAgGC2hmjDGQCAgGyIrmo4EwAQkA3RlQ1nAQACsiF6cMPZAICAbIiuaDwHABCQDdHl+gYAIJikEN0AAAjIhuhBjecCAAKyIbqs8TwAQEA2RJcOOg8AEJAN0SWDLgAABGRD9EB9AwAQjA3RxYO+BAAIKClELwQABGRDdNHgiwAAAdkQPUDfAAAEY0N04eCLAQAB2RDdf/AlAICAbIjOH/xlAEBANkT3G3IpACCgpBC9DAAQkA3ReUMuBwAEZEN0X30DABCMDdF9hlwBAAjIhuicoVcCAAKyIbr30KsAAAHZEJ099GoAQEBJIXoNACAgG6J7DbsGABCQDdFZw64FAARkQ3TPYdcBAAKyIbrHsOsBAAHZEJ057CsAgIC2hmjTRgBAQDZEP6dvAACCsSE6o+mrAICAbIju1nQDACAgG6LTm24EAARkQ3TX4TcBAAKyITpt+NcAAAERogDQCTZEpw6/GQAQkA3RnYffAgAIyIbolBGbAAAB2RDdacStAICAbIhO1jcAAMHYEJ044usAgIC2huhIfQcAIBAbohNG3gYACMiG6PiR3wAABGRDdNzIbwIAArIhOlbfAAAEY0N0zMhvAQACsiE6etTtAICAbIg2j/o2ACAgG6KjRn0HABCQDdGRo74LAAjIhuiI5u8CAAKyITq8+Q4AQEA2RJua7wQABGRDdFjz9wAAAdkQHdr8fQBAQDZEh4y+CwAQkA3RwfoGACAYG6KDRv8AABCQDdHG0T8EAARkQ7Rh9I8AAAHZEK0fczcAICAbogP1DQBAMDZE68b8BAAQkA3RWn0DABCMDdGaMT8FAARkQ3TA2HsAAAHZEK0eey8AICAbolX6BgAgGBuilWN/BgAIyIZoxbifAwACsiFaPu4+AEBANkTLxv0CABCQDdHScfcDAAKyIdpf3wAABGNDtGT8AwCAgGyIFo9/EAAQkA3RovG/BAAEZEO0cPyvAAAB2RAtGP8QACAgG6L5Ex4GAARkQzRP3wAABGNDtN+EXwMAArIhmjvhNwCAgGyI5kz4LQAgIBui2RMfAQAEZEM0a+LvAAAB2RDN1DcAAMHYEM2Y+HsAQEA2RNMnPgoACMiGaNqkxwAAAdkQTcgNAEAwNkQn/wEAEJQXomk7PQ4ACGhriO78BAAgoK0hOlXfAQAIxIZo+rQnAQABbQ3RXfQdAIBAtobo9D8CAAKyIZox4ykAQEBbQ/Rz+g4AQCA2RDNnPg0ACGhriO7+DAAgIBuiWXs+AwAIaGuIznoWABDQ1hDdS98BAAjEhmj27D8BAALaGqJzngMABGRDNGef5wAAAW0N0X2fBwAEtDVE570AAAjIhmju/BcAAAFtDdH9XwQABLQ1RBfoOwAAgdgQ7XfASwCAgLaG6KKXAQAB2RDNO/BlAEBAW0N0yZ8BAAFtDdHP/wUAEJAN0fylfwEABLQ1RA/aDAAIyIZowfLNAICAtobowa8AAALaGqIrXwUABGRDtPCQVwEAAW0N0dV/BQAEZEO06NDXAAABbQ3RNfoOAEAgW0N07esAgIBsiBav+xsAIKCtIXq4vgMAEIgN0ZIj3gAABLQ1RI/UdwAAAtkaoke9CQAIyAvR14uW/kL1P+YtAEAHFR/yqAToBxKi89JLBqn+X9TfAAB0SEZFs4ToCglRGar0i39Tpcf9HQDQAZKbLfHZMhakF9So0uO3AAB2IL1ooAToqpb4tCPt3fy9rlClJ+gHAQCcCuZ9TQdo2ietwekbqvTYV1TZSW8DANqRfJScbIlL96jWVNmJb6qyk/V/AgC00Lko+ajVSVhub4zQdOq+pcpOeQcAoPNQclGbLiHZkTFaU6VHPa3KT3sXAPqs0mOe8wJ0qoRjkFGgqYJ9r1Xl6/UPA4A+pmjR170AlU2dqY60f2VWjFQVZ7wHAH1G5oDxEp6fteRg58ftmir74rOq4sz3AaDXKjvhZa/7vEvCL8zRqKms2smq4iz9ywCgl8ke9DkvQGUHe5eNjZoq2v96VXnOBwDQ4xUfeKsXnrdJyEU1XtFU6ZG/VZUb9BMBgB6m7IuPe+H5lpapRT5KtM8S6Zmq/NgnVNW5HwJA7FWc/KJKy8z5r8mvzu15D20M1XSYZqjy43SYnqefKADEjOST5JTJq5bcit2QRP9fTRUtuEZVXfARAHS74iW3eG/bJZ9iGZ7th2xbeERTuWMXq+oL/wEAkeu30yFeeD6m5Wo9cpym6RY6U/U/5A5VfdHHANBl+q/+vmzv9MJzg4RQbxnl2vOaym6cpqrOelUNuPhjAOg0yRPJFckXTY4cisXOoq4c8rkksmFX9ZuwVA246EM14JJPAKDjdG70m7zCC07Jk7Vanxwtb/clUCcuVdUXbFEDLtUTBADtSD5ITniZoZ2pMZLGcZqZnOxBu6jKkx5TNZd9CqAPqzzlSZMHXjZo0ngxOjDkLf87mkrLzFXFB1yhaq74J4A+oHjxNWa9l/Vfk892b/+hcIyAQzYSmytJiZyhM1TFcb9UtVf+E0AvIOuzrNfeOq7doe3wYzgYqY8FmtnTL/ImL1NV6/+oaq/6XwA9gKyveVMOTg5NWZ8Xa4xuGodr5oIoImfYDFV2xI9U7TX/AhADsj7Keumto9rrmqy3jJiOOdqDmllg6f1KVNHe61XNRW+oumv/BaALyXom65usd946qMkZjPIOktFDh2xTvVT7WDMLNaumWZUsukzVXv6eqrvu3wBSIOtPyYFXqay6ccmBKeenX6mxTbOXD/noU7kAq134mRVDVNF+G1T1+S+puq/oIgFgDbhwsyre/wLTgCSvN5rs9J2lMRiJydq1mjm0ytNv3HxVfvidauD1/1QDN/4f0OtJvedNPCA5KIUcaiTrR+CPDmYwZFuOHHJhLvPn6Td2X9V/+fX6Lc1bauANnwE9itRt6cE3mDpOrmtNTqGUemdvOaPLh+zAkldm+WgBW4TpeSUqb6fPq7JDb1W1l72u6m/8DOgWdVe8ZepQ6lHqMrlONXnHJZ+ZJnXMYMRqyBWr5Iwr2VYkb4HaFG924yRVtPeJqvLYn6iB132o6m/6f0BKpH6kjormnmrqqn2tabIzVbpKqUepSwajVwzZqSUXTpDDsMzVrJKlF5SrfhP2V8ULz1OVJ/5c1V7xhqq/+T/oY+qu3mKWv9SB1ENGcXWbOmkl9SN1JNfNlLpiMBh6yKEhsj3qIk1WEF83KyRsc0d8ThXMWKNKl1+jqk65X9Vd/lfVcMt/EFN1V75hlpMsL1lusvxkObqWrybLXZa/HJ63VGvUGAxGiEOOf52pyZkfsm1LVrg2Rxa4ZJY36pV3piqYvkoV73+OKltzi6o69QFVd8VrqmHTf7EDMk/Vpz+kytd93cyfzKPMp8yra77bkeUjy+km7WhNlh/HUzIYPWxIRyMrr1wZ53xNjpd9WGuzg6wjJDhsKO+ywgRKyYJzVOlBV6jytbdY1ac90JYOobrLNrcx8Nq3VeOt/90heVz7/ys/r/3vSP798nzkecnzk+fphV4Hg689mSc5A0fmTeZPLgYs80mnyGAwAg8JDi+UZeeFBLNsn5MzVjYlke4rmYS2XO8g2Q676FbyuPb/V35e+9+R/Pvl+cjzkucnz1Oer3zqI8HHYDAYjC4f8kmZ8oIzQpMXICHbaeVFScgF1eVFSsg2XO/FS7r15Be25Be+Nsddo9vJTsrk5ZO83ORII2+ZyvL1lvVJmlcDUg9ebYzWpF567CesMhgMBoPB8I9MTV7g5QxlecGXgzikCZBPzJDGQPYvSrNwjyYNxMuaNBW+I+mCykxPVw2FhWp4SYmaUVNjHDB4sFrZ1GQcM2aMOnPSJOOCKVPUTTNnGpt2313dN2+e9dKyZdZHa9aof69bh5j4dO3aNssnebnJcvSW6cVTp9plLcvdq4ElQ4bY2pA6kXrJzchw1lNAXpMs9Sx1fZ8mdS71LnUv9Z/cDMv6IeuJrC8MBoPBYPTJUaJ5WxC9ZlF2b3lbCeVF1XkE8I7U5uercWVl5gV/fmNjm0bwql13Nc3CXXPmmAbiicWLafrQ40n9Sh0/vWSJqeu75841dS71LnV//NixZj2Q9UHWC1k/pBF2rT8dIOf5eVuFZWuwrLdes+tt8eX8PwaDwWB0yZCtKHLsk9dAyvm5suXlbu1JraPHYamCrCw1pKjIvDDK1iJpFr2thfJiKi+qb6xc6XzhBdB9ZL30ml5vK7A0uwcNG2bWZ1mvZf12rffbIG86n9Fkb4WcaSO54jW2kjccxsBgMBi9aHjNpFxtXc4mkmsQyJYNOcuoQ2dlydaUXaurTQMpL0CXTZumbp81S/124UL12ooVzhcvANgWyQ3JjztmzzZbck8eP97ki+RMgK238kb4MU3yTHJNTvmXS1lK3nEoAoPBYHTRkJCVsJXrdchuMtmqILu2XUFtyS5sCXnZirF+4kS7JVJ28bleKAAg7jYvX64emD/f5JkcliCHJEjOSd65crAdyU3JT/ksATnJcJ4mhxAxGAxGnxpyfJXskpJ3815j+brmCk5DdoXNHjhQHdHcbLZOyjGQsutMTrBwhTUAwO+5pUvNMbayVVYOF9qnvt6cXCYnJLqyt5XsSfIaWO8CnnIhVgaDwYjNKNDkbFXZFe41l9s8nrIqL88cayWNpQTiPfvuyy5vAIgpOW5W9ih5DaxsGJAcd+V7K8l/OeFLXg9ko4N8zrq8TjAYDEbgIWeJykWMJVDkwsdyVqkveOQddXNpqTnuSQ7ul62WNJcA0DdJ8ypbX+X1QA6RkqsZbGfLq7yuyOuLvM7IiVzjNY57ZTD6wJDjL+X6e7Lyy0HwzguNl+fmml04cqylHGwvxym5ggcAgFTI64q8vsjrjFyKazvHvcrrlLxeyaECspGE41wZjBgP2Zop7y7lEkRy+SHfSl2SnW12s8jKL1sxuaQQACDO5HVKXq82TJ5sNpLIxhLX65sml82SS2bJYWPyeshgMEIecuF0OaNcLuUhx+P4tmjKpUHkU3DkJB8525KLmwMA+gJ5vZPLZsnrnxweICe+tn+N1OR1Uw4LkNdRuZKAvK4yGIykIQd4S7Mpu899WzXlY/TkxB+5Lp0cj7Nl1SrnCgkAAPzeW73avH7KJbHk9XQbH1jwvCaHAyzQaFYZvXLIbgP5KDk547zNCUFygLdcK05WEtmqyWWLAACIjrzuPrRggTkcQJpV2QiU/DqtyZbV+zR5HZeryDAYsR1yYPVJmhRsm13pcjmMQ0eMULftuSdnnAMA0IPIHkl5/ZbXccfJVp9pcgidNKocr8qIZMgudTkj/TatzRZOOUFILnO0affdOTkIAIA+QBpVed2X41UdJ1hJn3CXJlcC4JqrjMCjTpOPTJOtnPKuxxaX7FK/YMoU84kWrsIEAACQPkFOrJK+wXHNVTmhSvoM6TcYfXzIOxV5xyLvXGzTKQc3y7sc2SwvBz67igwAACAo6SvkOqvSZ7Q7mUr6ENkIxpbUXjzkWA45U67NR1bKOxb5uDN2rQMAgO4iu/w3zphhTqJK7lO0DzS5jjgnT/WwIQtMFpw9rrM4O1utGzXKXI/MVQQAAABx8+iiReqI5ub2x6TKidKbtKkaIwZDPubyyrRE4kP9r1lIcrabXJeT4zoBAEBvIx+pKpeElA+98XofTRpU2RDHWf1dPOQYiqM1uTitmXw53kLeMdB4AgCAvuqlZcvU8WPHmj3BXo+kvazJiVJcyL8TQyZvgybHS5iJ3aO21hz4y8XhAQAAtk0+23/2wIHJzalsPZVPfKzWGNsYMjkySfai8fMbG83xEq5JBgAAQMdIP3XA4MEqMy2N5jRpZGprtbc0MzEySTSfAAAAXUsOcVzZ1OQ1pkKuOCS79aU/69VjvCYfnWX+8CFFRWa3u2uSAAAAEI27585VzaWlyc3pI1qvOWN/jvaKZjYNHzNmjLmelmsiAAAA0L0+WrPGXJkoaZf+69oCrUcN+Qx3c+JRTkaG+QhNTjoCAADoWaR/k482zc/K+q/0dZpcx32VFssh1/x8UjOfwypP3PVHAQAAoGeST4pKakyf0br92qZykOulmtmMK2e/swseAACgd5PP2W93ApR8KlSkJz/JZQAe1lRZbq56YP585xMFAABA7yYft16Vl+c1pbK1tEsvFyWbYs2lmHaurFSvrVjhfFIAAADoW2Tv+K7V1aYpTUskPtH/TtdCG9LhysdKmV3xnIwEAAAAF+kT5drx0jdqshFTzitKeci+f7M7XraEyvEBrl8KAAAAJJO+0dtSqsnu+wIt0JDrg5pLMz2xeLHzlwAAAADb89KyZcln4C+WJrMj4x7NfMC+64cCAAAAQSTtupe97ts9895cK5TrhAIAACBMN82c6TWkci6SsyGlEQUAAECX2V5Deq2m1k+c6PyPAAAAQBgunjrVa0hvkyZUxghN1ebnO/8DAAAAEKbhJSVeQ2quR7pRbshmU9eDAQAAgDDdtueebbaOmmNFuYQTAAAAovDc0qVeM/q8NKPmxkdr1jgfDAAAAIRJPqnJ60FtM3rfvHnOBwMAAABhemjBAn8zumHyZOeDAQAAgDAlnVG/tRkVm5cvd/4HAAAAIAxbVq1Smenp7mZUPtDe9Z8AAACAMOxTX5/ciIqWL05v/XdGTY3zPwIAAACdMb+x0fSbR7f2na1avvhUu6T1650rK81ZTq4fAgAAAAQlGzylz5QNoNJ3ej2otrUZFfdpGZrsy5cznVw/DAAAAOiIRxctUjkZGabf/EFrv7ndZlR8pO2iyf0HDRvm/MEAAADA9qwbNcr0k2O197TkftPrQTV/M+qRraT5icR/5ftnTprk/CUAAABAssumTTP9ZaZ2r+bqM70eVNt2M+r5hia77uVxV+26q/OXAgAAoG+Tz5zPTEszPePVmquv9Hg9qLbjZtRzgyYdrjxedt9zkhMAAEDfJv2gtzteNl5errn6yPa8HlTreDPqeUyr0uT/DS8pUU8sXux8cgAAAOidXlq2TE2qqDD9oPSFcninq2/cFq8H1YI3o54t2oGa9zNWNjWp91avdj5hAAAA9GyyFfSYMWNs77ef9qbm6hN3xPsZWssXrgcF8Yg2RJOfVZCVZQ5cZTc+AABAz7dxxgxVnJ1t+rwG7WHN1Q8G4fWgWjjNaDI54alGk58r1ys9efx49dGaNc4/DgAAAPEiGxQ3TJ5srw9apsm5Q66+L1VeD6qF34wme1AbpXm/Z8mQIeq5pUudfzgAAAC6x+bly80hl17PJnu8t3VZpjB4v0dr+cL1oLBt1lZo3hn5srn34qlT2WoKAAAQMdn6KZfsLMvNtY3hUu05zdXHhc37nVrLF64HdTXptuWK/N5zGFJUpG6aOZNjTQEAALrAHbNnq3FlZbb3kr3Xd2quPq2rec9Ba/nC9aAoyUeQyrEI3klQguYUAAAgNdI/SR8l/ZTtrTTpt6TvcvVjUfKek9byhetB3e3bWvKW0+Ls7P/K5QQ45hQAAKAtOebz+LFj7VnvIk7NZ3vec9RavnA9KG6e1A7XcjTveTeXlqprp0/nuFMAANBnSN+zaffd2+xyl/5olSaX23T1UXHjPW+t5QvXg+JOunzZerqXlvQHmQZVrnP6xsqVzgUIAADQU2xZtcqcaOR92pFnN00upxnHrZ4dkfS3tHzhelBPJAtEDsSdq3ln7Yva/Hy1fuJEProUAADElhyKKP1KQ2Gh7WGEbHjryY2nS9Lf1/KF60G9yY812XQtF21N+uPVjJoa86kC8q7DVRQAAABhk49Pl5OL9qitNR8Q5PUl+ZpcXkn6lt7UeLok9WMtX7ge1NvJZ+vfrMm7jeStqLkZGWr2wIGmSX1txQpnEQEAAOyIHDIo/cT8xkbTX3i9hvQdu2vXa9KPuPqU3s6bC63lC9eD+qrXNDnzTD78P/lkKTG8pMRsPn9owQJn0QEAgL7ntwsXmv4g+YQiIX2EbPSSplP6C1ff0VclzVPLF64Hoa33NG93f62WNIlmE/uu1dXqgilTOC4VAIBe6OklS8wnR8ohfsm71kWVJp8yKSdWS7/g6iPQVtL8tXzhehA67k3tVk0KUQoyaYJNwe5cWanOnDRJ3TdvHhfxBwAghuT1WfZ8yuu1NJzJu9WFnHcix3PKIX5s5ey8pLlt+cL1IIRDjgX5gXa0lnwRf095bq5aMmSIOaZE3nW5VhAAANB5cra6nDh00LBhqiovz/ea3KTJNc1lC6dsaHK9riMcSfPe8oXrQYjGc9rV2oFa+93/oiAry5xtJ+/U7tl3X3MGnmsFAwCgL5PXR9kDKa+XciKyvH62f02VvZfyeiuvu/JhOq7XZUQjabm0fOF6EOJB3pnJO7QTtSla+5OqhGxdlTP1NkyebBpWLlUFAOhNpNGU1zc5N0Ne71xbNeUMdXmdlD2R8rrJrvR4S1p2LV+4HoSeQ7auyjGrsgJO1JIvVeWRd4jy6Q1HNDebQwIeXbSI41cBAN1KXofkxF/5aMtjxowxJwO7tmjK65oc6ia70OWYzac11+sheo6k5dvyhetB6F02a/LpVGdrctkq1yEBQk64kktTHDpihPn4sQfmz2dLKwAgENmSKScDyeuIbASRjSHtTwjyyK5z+eTEUzXZovmS5nodQ++SVAMtX7gehL5JDguQS1hdqMlxNaM015ZWIcEiASON62XTppljdWhcAaB3knyXDRTSYK4bNcrkv2srppDXDXn9WKidp8nGEHabI1lSvbR84XoQsCNypYAHNTkQXA4R2E1r/5GrybxDBVY2NZlrtd0xezZXEACAbiJnlt81Z47JY8lluQxhSXa2M7+F5LvkvOwqv1yT/OeMc6QqqbZavnA9CAibNK8Pa3J8q5yQJYcLbG/Lq5Ctr82lpeaA9ePHjlXXTp9uDmLfvHy5M1wBoK+RPJRclHyUnJS8lNzc1m5xj1zGSHJY8lg+eVDyua9+NCWil1SLLV+4HgTEgXySxWPaNzTZ1SOfgLWL1v7DBVzkHb4c/3rA4MEmoGXXkmwFkK2xH61Z4wx1AIia5JHk0t1z59qGUnJL9iRtb0ulR7ZYylnkko+Sk5KXj2g0loizpBpu+cL1IKCnk5O2ZDeSnHkpJ25JUO+uNWhJK8F21ebnm11XXkMrx8bePmuWOW7qpWXLuCIB0IfJ+i85IHkguSD5IDkhH2QiZ4U3FBY6c8VFckl2gcsn+UleSW7dp0mOufIN6OmS6r/lC9eDgL7uI00um3WvJi8MssVBjpWSsz5lK0SQplbIMbNDiorMx8xJcysnfsnFmWWLrVzWRE4Ak0uccAgCEL7XVqww65esZ7K+yXon65+sh7I+ynop6+e2TsjZFrkyiVxST3JhrSaNpOzyltyQ/JAcceUL0NclrUctX7geBCBccqC/fOKHvEjJcbNy4tfpmryAyZULZKuIHMO1vZPAOkI+BEG2yMgWXXmBla00cnLCyePHmxdfuc6sfByeHGMmL8yyZUe4XsCBriBvuKTmpP6E1KPUpdTn+okTTb3KxzVK/UodSz27LnIehKxXQzRZz+QMb9lTIuufnIgjbzZlvZT1kzO+gWgkrZ8tX7geBKBnkmv0yRYZ2cXnbdWVLTXywitkN6CQF2U5/la28G7rurNhkGPepJkQclKFNBhCPuZWmg6PNCIer2EWcpyv17TIhzV4zXN7rqant3L9/ULmx5srOf7Qm0Ov0fMkz7t8bKK3TGT5eMtK3tS4lmcYpN6k7qT+pA6XalKTXo1KvXpbF6WOpZ659iTQuyRlQssXrgcBQBhkS5M0E0JORpMGQ/xA85qO5GZZyFYrr2mW3Z/SsAj5BBZpYlySgq3Xc/39QubHm6u9NG8Ova2Anus1b95lOXjLRE568ZYVWwgBdKWkTGv5wvUgAAAAoCvQjAIAAKDb0IwCAACg29CMAgAAoNvQjAIAAKDb0IwCAACg29CMAgAAoNvQjAIAAKDb0IwCAACg29CMAgAAoNvQjAIAAKDb0IwCAACg2/ia0U8AAACAiDia0TQAAAAgEr5m9GN9JwAAABAFmlEAAAB0G0czmg4AAABEwteM/kPfCQAAAETB34ym6W8AAAAAEfA1ox+lZQAAAACRoBkFAABAt6EZBQAAQLfxNaMfpmUCAAAAkaAZBQAAQLfxNaMf6DsBAACAKDia0SwAAAAgEr5m9H19JwAAABAFRzOaDQAAAESCZhQAAADdxteMvpeeDQAAAETC0YzmAAAAAJHwNaPv6jsBAACAKNCMAgAAoNv4mtF30nMBAACASNCMAgAAoNvQjAIAAKDb+JrRt9P7AQAAAJGgGQUAAEC3oRkFAABAt/E1o1vS8wAAAIBI0IwCAACg2/ia0b9n5AEAAACRcDSj+QAAAEAkfM3oW/pOAAAAIAo0owAAAOg2jma0AAAAAIiErxl9U98JAAAARIFmFAAAAN3G14y+kVEIAAAARIJmFAAAAN3G14z+Td8JAAAARMHRjBYBAAAAkaAZBQAAQLfxNaOvZxYBAAAAkXA0o8UAAABAJHzN6Gv6TgAAACAKjma0BAAAAIgEzSgAAAC6ja8Z/au+EwAA"
               + "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",
          fileName="modelica://TransiEnt/Images/thermalStorage.png"),
        Bitmap(
          extent={{-8,2},{62,-94}},
          imageSource="iVBORw0KGgoAAAANSUhEUgAAATkAAAE5CAMAAADcP6fDAAAACXBIWXMAABcSAAAXEgFnn9JSAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAYZQTFRFAAAAAAD/Dw//Hx//Ly//Pz8/Pz//T0//X19fX1//b2//f39/j4//n5+fn5//v7+/v7//z8//39//7+//////////////////////////////////////////////////////////////////AAAAAAD/DAwMDgECDwsDDw8PDw//GRkZHQMEHxYHHx8fHx//JiYmLAUGLyELLy8vLy//MzMzOwcJPiwOPz8/Pz//SggLTExMTjcST09PT0//WAoNWVlZXkIWX19fX1//ZmZmZwwPbU0Zb29vb2//cnJydg4SfVgdf39/f3//hQ8UjIyMjWMhj4+Pj4//lBEWmZmZnG4kn5+fn5//ohMYpaWlrHkor6+vr6//sRUbsrKyvIQsv7+/v7//wBYdy48vzMzMzxgfz8/Pz8//25oz3hoh39/f39//66U37Rwk7+/v7+//+7A7/wAA/w8P/x8f/y8v/z8//09P/19f/29v/39//4+P/5+f/6+v/7+//8/P/9/f/+/v////kIefhAAAACR0Uk5TAAAAAAAAAAAAAAAAAAAAAAAAAAAADx8vP09fb3+Pn6+/z9/v4vdPWQAAFjRJREFUeNrtnftf20a2wJvu3b13d7t72638fiBbYxeb2KaAsZ0ACTYFUuwGSLALgdguKaQ2wdA23d32blv951fyQxppJFmPkayHzw/99COTwfpyzpzHnJn54APbSCAYikbjJElStFgSzNNoNBIM+j6YCyQMsbgELmlJkAxBv+eZ+UPRhSStR8hYJOhRaL5gVLWeyepfPBzwGLVQLEFjEmoh4hV6wSg2ahy9eNjtM58vHKdocyQRDbgY2wJtqiRjgTm2ObyxhCzBNoYXdc2c549RtLVCht3ALUzSMxAq5nDF80UpelZCOjjH8MfpmUrSoUYbJOmZCxX1zbl5hJ1duDmNnZ24OYldwGbcRuzm/tStfnaW8Zuj47tQkrazxO063flJ2uZCRWwJLko7QBL2K0IFk7QzJGYvk/XFaMdIMjhXOMernZMUzlZqF0jQzhM75BQR2pGSmHXN2EfSDhVqtulYkKKd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")}),
                                                                 Diagram(coordinateSystem(preserveAspectRatio=false, extent={
            {-160,-140},{140,120}})),
    Documentation(info="<html>
<h4><span style=\"color: #008000\">1. Purpose of model</span></h4>
<p>Combination of storage tank, solar collector, controller and gas boiler. Stratified storage tank is divided into ten layers to allow for better resolustion of storage temperatures: top two layers are heated by boiler to T_boiler. Energy for space heating is extracted from top six layers, energy for DHW from all ten layers. Solar energy is fed into bottom to sixth layer.</p>
<h4><span style=\"color: #008000\">2. Level of detail, physical effects considered, and physical insight</span></h4>
<p>(Purely technical component without physical modeling.)</p>
<h4><span style=\"color: #008000\">3. Limits of validity </span></h4>
<p>(Purely technical component without physical modeling.)</p>
<h4><span style=\"color: #008000\">4. Interfaces</span></h4>
<p>(no remarks)</p>
<h4><span style=\"color: #008000\">5. Nomenclature</span></h4>
<p>(no elements)</p>
<h4><span style=\"color: #008000\">6. Governing Equations</span></h4>
<p>(no equations)</p>
<h4><span style=\"color: #008000\">7. Remarks for Usage</span></h4>
<p>All components use energy based modeling without consideration of fluid flow. </p>
<p>Heat flow into the storage tank is based on the difference between the temperature of each tank level and the respective source or sink temperature. </p>
<p>Electric energy for the pumps is not accounted for.</p>
<h4><span style=\"color: #008000\">8. Validation</span></h4>
<p>(no validation or testing necessary)</p>
<h4><span style=\"color: #008000\">9. References</span></h4>
<p>(no remarks)</p>
<h4><span style=\"color: #008000\">10. Version History</span></h4>
<p>Model created by Anne Hagemeier (anne.hagemeier@umsicht.fraunhofer.de), Nov 2019</p>
</html>"));
end SolarThermalSystem_10LayerStorage;
