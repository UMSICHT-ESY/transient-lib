within TransiEnt.Consumer.Systems.HouseholdEnergyConverter.Systems;
model test_complex "Test System with ComplexPowerPorts"

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

  TransiEnt.Components.Boundaries.Electrical.ComplexPower.PQBoundary     pQBoundary(    useInputConnectorQ=false, useInputConnectorP=true,
    cosphi_boundary=0.9)                                                                                                                   annotation (Placement(transformation(extent={{-62,-28},
            {-46,-12}})));

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
  elseif heating then
  else
  end if;

  if not hotwater then
  else
    connect(demand.electricPowerDemand, pQBoundary.P_el_set) annotation (Line(points={{4.68,
            100.48},{4.68,-2},{-58.8,-2},{-58.8,-10.4}},                                                                                 color={0,127,127}));
  end if;

  connect(pQBoundary.epp, epp) annotation (Line(
      points={{-62,-20},{-80,-20},{-80,-98}},
      color={28,108,200},
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
end test_complex;
