within TransiEnt.Consumer.Systems.HouseholdEnergyConverter.Systems.Control_Battery;
model MaxSelfConsumption "Maximizing self-consumption"




//________________________________________________________________________________//
// Component of the TransiEnt Library, version: 2.0.3                             //
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
// Gas- und WÃ¤rme-Institut Essen						  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//





  extends
    TransiEnt.Consumer.Systems.HouseholdEnergyConverter.Systems.Control_Battery.Base.Controller_PV_Battery;

 // _____________________________________________
 //
 //                   Interfaces
 // _____________________________________________

  Modelica.Blocks.Math.Add add2(k2=-1) annotation (Placement(transformation(extent={{-2,-18},
            {18,2}})));

  Modelica.Blocks.Logical.Switch switch1 annotation (Placement(transformation(extent={{62,-10},
            {82,10}})));
  Modelica.Blocks.Sources.RealExpression zero(y=0) annotation (Placement(transformation(extent={{-2,12},
            {16,30}})));
  Modelica.Blocks.Sources.RealExpression zero2(y=0.999)
                                                    annotation (Placement(transformation(extent={{0,-40},
            {18,-22}})));
  Modelica.Blocks.Interfaces.RealInput SOC annotation (Placement(transformation(extent={{-13,-13},
            {13,13}},
        rotation=90,
        origin={-9,-103}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={0,-94})));
  Modelica.Blocks.Math.Min min1
    annotation (Placement(transformation(extent={{38,2},{50,14}})));
  Modelica.Blocks.Sources.RealExpression zero3(y=0.99) annotation (Placement(transformation(extent={{-2,-56},
            {16,-38}})));
  Basics.Blocks.Hysteresis_inputVariable           hysteresis_heater annotation (Placement(transformation(extent={{38,-44},
            {52,-30}})));
equation

 // _____________________________________________
 //
 //                   Connect statements
 // _____________________________________________

  connect(P_PV, add2.u1) annotation (Line(points={{-104,60},{-62,60},{-62,-2},{
          -4,-2}},                                                                             color={0,0,127}));
  connect(P_Consumer, add2.u2) annotation (Line(points={{-104,-60},{-62,-60},{
          -62,-14},{-4,-14}},                                                                          color={0,0,127}));
  connect(switch1.y, P_set_battery)
    annotation (Line(points={{83,0},{104,0}}, color={0,0,127}));
  connect(add2.y, switch1.u3)
    annotation (Line(points={{19,-8},{60,-8}}, color={0,0,127}));
  connect(min1.y, switch1.u1)
    annotation (Line(points={{50.6,8},{60,8}}, color={0,0,127}));
  connect(zero.y, min1.u1) annotation (Line(points={{16.9,21},{30,21},{30,11.6},
          {36.8,11.6}}, color={0,0,127}));
  connect(add2.y, min1.u2) annotation (Line(points={{19,-8},{26,-8},{26,4},{36,
          4},{36,4.4},{36.8,4.4}}, color={0,0,127}));
  connect(SOC, hysteresis_heater.u) annotation (Line(points={{-9,-103},{-9,-38},
          {32,-38},{32,-36},{37.3,-36},{37.3,-37}}, color={0,0,127}));
  connect(zero3.y, hysteresis_heater.uLow) annotation (Line(points={{16.9,-47},
          {34,-47},{34,-44},{37.3,-44},{37.3,-42.6}}, color={0,0,127}));
  connect(zero2.y, hysteresis_heater.uHigh) annotation (Line(points={{18.9,-31},
          {31.45,-31},{31.45,-31.4},{37.58,-31.4}}, color={0,0,127}));
  connect(hysteresis_heater.y, switch1.u2) annotation (Line(points={{52.7,-37},
          {54,-37},{54,0},{60,0}}, color={255,0,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">1. Purpose of model</span></b></p>
<p>Control model for a PV battery to maximize self-consumption. Battery will be charged as soon as PV power exceeds the electricty demand.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(Purely technical component without physical modeling.)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">3. Limits of validity </span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(Purely technical component without physical modeling.)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">4. Interfaces</span></b></p>
<p>Modelica.Blocks.Interfaces.RealInput <b>P_PV</b></p>
<p>Modelica.Blocks.Interfaces.RealInput<b> P_Consumer</b></p>
<p>Modelica.Blocks.Interfaces.RealOutput <b>P_set_battery</b></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">5. Nomenclature</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">6. Governing Equations</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">7. Remarks for Usage</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">8. Validation</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">9. References</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">10. Version History</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model created by Anne Hagemeier, Fraunhofer UMSICHT in 2018</span></p>
</html>"));
end MaxSelfConsumption;
