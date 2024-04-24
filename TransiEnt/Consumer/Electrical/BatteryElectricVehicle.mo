within TransiEnt.Consumer.Electrical;
model BatteryElectricVehicle

//________________________________________________________________________________//
// Component of the TransiEnt Library, version: 2.0.2                             //
//                                                                                //
// Licensed by Hamburg University of Technology under the 3-BSD-clause.           //
// Copyright 2021, Hamburg University of Technology.                              //
//________________________________________________________________________________//
//                                                                                //
// TransiEnt.EE, ResiliEntEE, IntegraNet and IntegraNet II are research projects  //
// supported by the German Federal Ministry of Economics and Energy               //
// (FKZ 03ET4003, 03ET4048, 0324027 f 03EI1008).                                //
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

  outer TransiEnt.SimCenter simCenter;
  extends TransiEnt.Basics.Icons.Model;

  // _____________________________________________
  //
  //              Parameters
  // _____________________________________________

  parameter String inputDataType="Distance" "Choose data type format: 'Distance travelled' or 'SoC at the arrival back home'"
    annotation (Dialog(group="Data"), choices(__Dymola_radioButtons=true,
                choice="Distance",
                choice="SoC"));

  parameter Real vehicleEfficiency=18  "[kWh/100km] Average electricity use per kilometer"    annotation (Dialog(group=
          "Electric Vehicle", enable=inputDataType == "Distance"));

  parameter SI.Power P_max_BEV_drive(displayUnit="kW")=200000 "Maximum driving power"  annotation (Dialog(group=
          "Electric Vehicle"));

  parameter SI.Power P_max_BEV_charge(displayUnit="kW")=22000 "Maximum charging power" annotation (Dialog(group=
          "Electric Vehicle"));

  parameter SI.Energy C_Bat(displayUnit="kWh")=252000000 "Battery capacity"  annotation (Dialog(group=
          "Electric Vehicle"));

  parameter Real SOCStart=0.7 "Battery state of charge at the start of the simulation" annotation (Dialog(group="Electric Vehicle"));


//   parameter String relativepath_Distance="emobility/CarDistance.txt"
//     "Path relative to source directory for car distance table"  annotation (Dialog(group="Data",
//         enable=inputDataType == "Distance"));
//   parameter String relativepath_carLocation="emobility/CarLocation.txt"
//     "Path relative to source directory for car location table"  annotation (Dialog(group="Data",
//         enable=inputDataType == "Distance"));

// parameter Real timeStepSize(unit="min") = 1
//    "Time step size of distance travelled, must correspond to time step size of chosen table"   annotation (Dialog(group="Data",
//        enable=inputDataType == "Distance"));

  parameter Integer column=1 "Table column for vehicle and location data" annotation (Dialog(group="Data",
        enable=inputDataType == "Distance"));
//   parameter Integer column_Distance=1 "Table column for vehicle distance data" annotation (Dialog(group="Data",
//         enable=inputDataType == "Distance"));

  parameter Modelica.Units.SI.Power P_chargingStation(displayUnit="kW") = 11000 "Charging power of the charging station" annotation (Dialog(group="Charging station"));
  parameter Boolean ChargeAtWork=true annotation (Dialog(group="Charging - Select if vehicle ist charged at different locations than home. Charging power will not be accounted for but will reduce charging load at home. Locations need to be specified in Input table", joinNext=true,
      enable=inputDataType == "Distance"),                                                                                                                                                                                                        choices(checkBox=true));
  parameter Boolean ChargeAtSchool=false annotation (Dialog(group="Charging - Select if vehicle ist charged at different locations than home. Charging power will not be accounted for but will reduce charging load at home. Locations need to be specified in Input table", joinNext=true,
      enable=inputDataType == "Distance"),choices(checkBox=true));
  parameter Boolean ChargeAtShopping=false annotation (Dialog(group="Charging - Select if vehicle ist charged at different locations than home. Charging power will not be accounted for but will reduce charging load at home. Locations need to be specified in Input table", joinNext=true,
      enable=inputDataType == "Distance"),choices(checkBox=true));
  parameter Boolean ChargeAtOther=false annotation (Dialog(group="Charging - Select if vehicle ist charged at different locations than home. Charging power will not be accounted for but will reduce charging load at home. Locations need to be specified in Input table",
      enable=inputDataType == "Distance"),choices(checkBox=true));

  parameter Real SOCLimit=1 "Maximum battery level";

  parameter Boolean useExternalControl = false "Checkbox to enable external load control"  annotation (
      Evaluate=true,
      HideResult=true,
      choices(checkBox=true),
      Dialog(group="Load Management"));
  parameter String controlType = "limit" "Load control method" annotation (
       Dialog(enable=useExternalControl, group="Load Management"),
       choices(choice="limit",
               choice="proportional"));


  // _____________________________________________
  //
  //              Variables
  // _____________________________________________

   //Real carLoc "Number representing car location (1=Home)";
  // Real derLoc "Derivative of car location";
  // Boolean carHome "True, if car is parked at home";
  // Modelica.Units.SI.Power P_driving "Current consumption of driving car";

  Real SoC=vehicleBattery.SOC.y;
  // _____________________________________________
  //
  //              Complex Components
  // _____________________________________________

  TransiEnt.Components.Boundaries.Electrical.ApparentPower.ApparentPower powerToGrid(
    useInputConnectorQ=false,
    Q_el_set_const=0,
    useCosPhi=false)
    annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={62,-78})));

  TransiEnt.Storage.Electrical.LithiumIonBattery vehicleBattery(
    use_PowerRateLimiter=false, StorageModelParams=TransiEnt.Storage.Electrical.Specifications.LithiumIon(
        E_start=SOCStart*C_Bat,
        E_max=C_Bat,
        E_min=10000,
        P_max_unload=P_max_BEV_drive,
        P_max_load=P_max_BEV_charge,
        T_plant=5))
    annotation (Placement(transformation(extent={{74,-16},{38,20}})));


  Modelica.Blocks.Sources.RealExpression P_batteryToGrid(y=if noEvent(
        P_set_battery.u2) then -vehiclePowerBoundary.epp.P else 0)
                                               annotation (Placement(transformation(extent={{2,-70},
            {54,-46}})));
  TransiEnt.Components.Boundaries.Electrical.ActivePower.Frequency vehiclePowerBoundary(
      useInputConnector=false) annotation (Placement(transformation(extent={{28,10},{12,-6}})));

  Modelica.Blocks.Math.Min min1 if useExternalControl and controlType == "limit"  annotation (Placement(transformation(extent={{-22,12},
            {-8,26}})));
  Modelica.Blocks.Math.Product product1 if  useExternalControl and controlType == "proportional" annotation (Placement(transformation(extent={{-20,-36},
            {-6,-22}})));
  Modelica.Blocks.Logical.Switch P_set_battery  annotation (Placement(transformation(extent={{54,62},{74,42}})));
  Modelica.Blocks.Sources.RealExpression chargingStationPower(y=P_charge_SoC.y) if not useExternalControl annotation (Placement(transformation(extent={{12,18},{38,36}})));
  Modelica.Blocks.Sources.RealExpression drivingPower(y=-vehicleEfficiency/100 * Distance.y[1]/Distance.r * 3600) if  inputDataType=="Distance" annotation (Placement(transformation(extent={{42,70},
            {76,90}})));

  Modelica.Blocks.MathBoolean.Or charging(nu=5) if inputDataType=="Distance" annotation (Placement(transformation(extent={{6,56},{24,74}})));
  Modelica.Blocks.Sources.BooleanExpression presence(y=vehicleHome.y) if inputDataType=="Distance" annotation (Placement(transformation(extent={{-40,84},{-20,100}})));
  Modelica.Blocks.Sources.BooleanExpression school(y=if ChargeAtSchool then (abs(4 - Location.y[1]) < 0.5 and (abs(derLoc.y) < 0.01)) else false) if inputDataType=="Distance" annotation (Placement(transformation(extent={{-64,62},
            {-44,78}})));
  Modelica.Blocks.Sources.BooleanExpression shopping(y=if ChargeAtShopping then (abs(2 - Location.y[1]) < 0.5 and (abs(derLoc.y) < 0.01)) else false) if inputDataType=="Distance" annotation (Placement(transformation(extent={{-66,78},
            {-46,94}})));
  Modelica.Blocks.Sources.BooleanExpression event(y=if ChargeAtOther then (abs(3 - Location.y[1]) < 0.5 and (abs(derLoc.y) < 0.01)) else false) if inputDataType=="Distance" annotation (Placement(transformation(extent={{-40,68},
            {-20,84}})));
  Modelica.Blocks.Sources.BooleanExpression work(y=if ChargeAtWork then (abs(5 - Location.y[1]) < 0.5 and (abs(derLoc.y) < 0.01)) else false) if inputDataType=="Distance" annotation (Placement(transformation(extent={{-42,54},
            {-22,70}})));


  //Data tables

   replaceable model DistanceTable = TransiEnt.Basics.Tables.ElectricGrid.Electromobility.DistanceProfiles_family_15min    constrainedby
    TransiEnt.Basics.Tables.ElectricGrid.Electromobility.Base.DistanceTable(multiple_outputs=true, columns={column + 1}) "Data table for data time series of distance travelled" annotation (choicesAllMatching=true,Dialog(group="Data",
        enable=inputDataType == "Distance"));
     DistanceTable Distance if  inputDataType=="Distance" annotation (Placement(transformation(extent={{-94,-60},{-80,-46}})));

   replaceable model LocationTable = TransiEnt.Basics.Tables.ElectricGrid.Electromobility.LocationProfiles_family_15min    constrainedby
    TransiEnt.Basics.Tables.ElectricGrid.Electromobility.Base.LocationTable(multiple_outputs=true,columns={column + 1}) "Data table for data time series of vehicle location" annotation (choicesAllMatching=true,Dialog(group="Data",
        enable=inputDataType == "Distance"));
     LocationTable Location if  inputDataType=="Distance" annotation (Placement(transformation(extent={{-94,-90},{-80,-76}})));

   replaceable model soCTable = TransiEnt.Basics.Tables.ElectricGrid.Electromobility.SoCTable constrainedby TransiEnt.Basics.Tables.ElectricGrid.Electromobility.Base.SoCTable(
                                                                       multiple_outputs=true) "Data table for data time series of battery SoC" annotation (choicesAllMatching=true,Dialog(group="Data",
        enable=inputDataType == "SoC"));
   soCTable soC_data if inputDataType=="SoC" annotation (Placement(transformation(extent={{-92,48},{-78,62}})));


  // _____________________________________________
  //
  //              Interfaces
  // _____________________________________________

  Modelica.Blocks.Interfaces.RealInput P_limit if useExternalControl and controlType == "limit"  "Interface for Load Regulation" annotation (Placement(transformation(extent={{-130,4},
            {-92,42}}), iconTransformation(extent={{-130,4},{-92,42}})));
  Modelica.Blocks.Interfaces.RealInput p_control if useExternalControl and controlType == "proportional" "Interface for Load Regulation" annotation (Placement(transformation(extent={{-128,
            -52},{-90,-14}}),
                            iconTransformation(extent={{-128,-52},{-90,-14}})));
  TransiEnt.Basics.Interfaces.Electrical.ApparentPowerPort epp annotation (Placement(transformation(extent={{90,-10},{110,10}})));
  Modelica.Blocks.Interfaces.RealInput SoC_consumption_internal;
  Modelica.Blocks.Sources.RealExpression zero(y=0) if inputDataType=="SoC"
    annotation (Placement(transformation(extent={{42,84},{76,104}})));

  Modelica.Blocks.Sources.RealExpression derLoc(y=if Location.smoothness == Modelica.Blocks.Types.Smoothness.ConstantSegments then 0 else der(Location.y[1])) if                                                                           inputDataType=="Distance"
    annotation (Placement(transformation(extent={{-56,-102},{-28,-82}})));
  Modelica.Blocks.Sources.BooleanExpression vehicleHome(y=abs(1 - Location.y[1]) <
        0.5 and (abs(derLoc.y) < 0.01)) if inputDataType=="Distance"
    annotation (Placement(transformation(extent={{-56,-84},{-28,-68}})));
  Modelica.Blocks.Logical.Hysteresis hysteresis(uLow=SOCLimit - 0.005,uHigh=
        SOCLimit)
    annotation (Placement(transformation(extent={{-76,-16},{-60,0}})));
  Modelica.Blocks.Sources.RealExpression soC(y=SoC)
    annotation (Placement(transformation(extent={{-100,-16},{-82,0}})));
  Modelica.Blocks.Logical.Switch P_charge_SoC annotation (Placement(transformation(extent={{-52,0},{-36,-16}})));
  Modelica.Blocks.Sources.RealExpression zero1(y=0)
    annotation (Placement(transformation(extent={{-80,-36},{-68,-20}})));
  Modelica.Blocks.Sources.RealExpression P(y=P_chargingStation)
    annotation (Placement(transformation(extent={{-78,6},{-66,20}})));
equation

  //equations for input type Soc

  if inputDataType=="SoC" then
    when P_set_battery.u2 then
    reinit(vehicleBattery.storageModel.E, max(vehicleBattery.storageModel.SOC - SoC_consumption_internal, 0)*(vehicleBattery.StorageModelParams.E_max
       - vehicleBattery.StorageModelParams.E_min) + vehicleBattery.StorageModelParams.E_min);
    end when;
  end if;

  //equations for input type Distance
    if inputDataType=="Distance" then
    SoC_consumption_internal=0;
  end if;

  //carLoc = carLocation.y[1];
 // derLoc = if carLocation.smoothness == Modelica.Blocks.Types.Smoothness.ConstantSegments then 0 else der(carLocation.y[1]);
//  carHome = abs(1 - carLocation.y[1]) < 0.5 and (abs(derLoc) < 0.01);
 // P_driving = -vehicleEfficiency/100 * Distance.y[1] * 60 / timeStepSize;

  //connect statements
  connect(vehiclePowerBoundary.epp, vehicleBattery.epp) annotation (Line(
      points={{28,2},{38,2}},
      color={0,135,135},
      thickness=0.5));
  connect(powerToGrid.epp, epp) annotation (Line(
      points={{72,-78},{86,-78},{86,0},{100,0}},
      color={0,127,0},
      thickness=0.5));
  connect(P_batteryToGrid.y, powerToGrid.P_el_set) annotation (Line(points={{56.6,-58},{68,-58},{68,-66}}, color={0,0,127}));
  connect(P_limit,min1. u1) annotation (Line(points={{-111,23},{-23.4,23.2}},                     color={0,0,127}));
  connect(p_control, product1.u2) annotation (Line(points={{-109,-33},{-26,-33},
          {-26,-33.2},{-21.4,-33.2}},                                                                       color={0,0,127}));
  connect(P_set_battery.y, vehicleBattery.P_set) annotation (Line(points={{75,52},{80,52},{80,28},{56,28},{56,18.92}},
                                               color={0,0,127}));
  connect(min1.y, P_set_battery.u1) annotation (Line(points={{-7.3,19},{0,19},{0,44},{52,44}},
                           color={0,0,127}));
  connect(product1.y, P_set_battery.u1) annotation (Line(points={{-5.3,-29},{4,-29},{4,44},{52,44}},
                                 color={0,0,127}));
  connect(chargingStationPower.y, P_set_battery.u1) annotation (Line(points={{39.3,27},{46,27},{46,44},{52,44}},
                                             color={0,0,127}));
  connect(drivingPower.y, P_set_battery.u3) annotation (Line(points={{77.7,80},{86,80},{86,68},{52,68},{52,60}},
                                    color={0,0,127}));
  connect(presence.y, charging.u[1]) annotation (Line(points={{-19,92},{-2,92},{-2,70.04},{6,70.04}}, color={255,0,255}));
  connect(school.y, charging.u[2]) annotation (Line(points={{-43,70},{2,70},{2,67.52},{6,67.52}},       color={255,0,255}));
  connect(event.y, charging.u[3]) annotation (Line(points={{-19,76},{6,76},{6,65}},    color={255,0,255}));
  connect(shopping.y, charging.u[4]) annotation (Line(points={{-45,86},{-2,86},{-2,62.48},{6,62.48}},     color={255,0,255}));
  connect(work.y, charging.u[5]) annotation (Line(points={{-21,62},{-2,62},{-2,66},{2,66},{2,59.96},{6,59.96}},
                                                                                                      color={255,0,255}));
  connect(charging.y, P_set_battery.u2) annotation (Line(points={{25.35,65},{40,65},{40,52},{52,52}}, color={255,0,255}));
  connect(zero.y, P_set_battery.u3) annotation (Line(points={{77.7,94},{86,94},{86,68},{52,68},{52,60}},
                                                     color={0,0,127}));
  connect(soC_data.isConnected, P_set_battery.u2) annotation (Line(points={{-78.7,57.8},{-46,57.8},{-46,50},{-2,50},{-2,52},{52,52}},
                                                               color={255,0,255}));
  connect(SoC_consumption_internal,soC_data.SoC_consumption);
  connect(soC.y, hysteresis.u)
    annotation (Line(points={{-81.1,-8},{-77.6,-8}}, color={0,0,127}));
  connect(hysteresis.y, P_charge_SoC.u2) annotation (Line(points={{-59.2,-8},{-53.6,-8}}, color={255,0,255}));
  connect(P_charge_SoC.y, min1.u2) annotation (Line(points={{-35.2,-8},{-30,-8},{-30,14},{-23.4,14},{-23.4,14.8}}, color={0,0,127}));
  connect(P_charge_SoC.y, product1.u1) annotation (Line(points={{-35.2,-8},{-30,-8},{-30,-26},{-21.4,-26},{-21.4,-24.8}}, color={0,0,127}));
  connect(P.y, P_charge_SoC.u3) annotation (Line(points={{-65.4,13},{-58,13},{-58,-1.6},{-53.6,-1.6}}, color={0,0,127}));
  connect(P_charge_SoC.u1, zero1.y) annotation (Line(points={{-53.6,-14.4},{-52,-14.4},{-52,-28},{-67.4,-28}}, color={0,0,127}));
  annotation (
      Diagram(graphics={
        Line(
          points={{-58,-78}},
          color={28,108,200},
          pattern=LinePattern.Dot),
        Line(
          points={{20,-12},{20,-10},{20,-14},{20,-22},{20,-46}},
          color={0,0,0},
          pattern=LinePattern.Dot,
          arrow={Arrow.None,Arrow.Filled})}),
    Icon(graphics={
        Line(points={{20,-28}}, color={0,0,0}),
        Polygon(
          points={{-66,2},{60,2},{72,-28},{-80,-28},{-66,2}},
          lineColor={238,46,47},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{14,-14},{42,-42}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-56,-14},{-28,-42}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-40,34},{36,34},{50,0},{-54,0},{-40,34}},
          lineColor={238,46,47},
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{50,-8},{54,-12}},
          lineColor={0,0,0},
          lineThickness=1,
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Line(
          points={{52,-10},{60,-12},{66,-10},{70,-4},{74,0},{84,0},{92,-4},{100,
              0},{96,-2}},
          color={0,140,72},
          thickness=1)}),
    experiment(StopTime=0, __Dymola_Algorithm="Dassl"),
    Documentation(info="<html>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">1. Purpose of model</span></b></p>
<p>Simple model of an electric vehicle battery. Table-based profiles of the vehicle location and the kilometers driven determine the state-of-charge of the vehicle. When the vehicle ist home, it will charge from the grid. It can be selected wheather charging will occur only at home or also at other places, thus affecting the state-of-charge. </p>
<p>The wall box charging power can be externally controlled by reducing the charging power proportionally or by setting a fixed maximum charging power.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">3. Limits of validity </span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">4. Interfaces</span></b></p>
<p>epp: apparent power port</p>
<p>optional: RealInput P_limit or p_control for external load management.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">5. Nomenclature</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">6. Governing Equations</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Both can be set: the maximum charging power of the electric vehicle and the maximum charging power of the charging station. Charging power will be the minimum of those two values.</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">7. Remarks for Usage</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">8. Validation</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">9. References</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">10. Version History</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model created by Dorian H&ouml;ffner, Fraunhofer UMSICHT in December 2021</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model modified by Anne Hagemeier, Fraunhofer UMSICHT, in June 2022</span></p>
</html>"));
end BatteryElectricVehicle;
