within TransiEnt.Consumer.Electrical.Check;
model CheckElectricCarWithControl

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

  extends TransiEnt.Basics.Icons.Checkmodel;

  // _____________________________________________
  //
  //           Instances of other Classes
  // _____________________________________________

  inner TransiEnt.SimCenter simCenter(
    useExternalControl=true,
    controlType="proportional",       tableInterpolationSmoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments)
                                      annotation (Placement(transformation(extent={{-90,80},{-70,100}})));

// _____________________________________________
//
//           Functions
// _____________________________________________

  ElectricCar electricCar(
    Bat_Capacity(displayUnit="kWh"),
    useExternalControl=true,
    ChargeAtWork=true,
    ChargeAtSchool=true,
    ChargeAtShopping=true,
    ChargeAtOther=true)
    annotation (Placement(transformation(extent={{-36,-12},{-8,16}})));
  TransiEnt.Components.Boundaries.Electrical.ApparentPower.FrequencyVoltage
                                                               ElectricGrid(
    Use_input_connector_f=false,
    Use_input_connector_v=false,
    v_boundary=400)
    annotation (Placement(transformation(extent={{20,14},{48,-14}})));
  Modelica.Blocks.Sources.RealExpression
                               GridVoltage(y=0.8)
               annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-84,-14})));
  Modelica.Blocks.Sources.RealExpression
                               GridVoltage1(y=1000)
               annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-84,10})));
equation

  // _____________________________________________
  //
  //               Connect Statements
  // _____________________________________________

  connect(ElectricGrid.epp, electricCar.epp) annotation (Line(
      points={{20,0},{6,0},{6,2},{-8,2}},
      color={0,127,0},
      thickness=0.5));
  connect(GridVoltage.y, electricCar.p_control) annotation (Line(points={{-73,
          -14},{-42,-14},{-42,-2.48},{-36.84,-2.48}}, color={0,0,127}));
  connect(GridVoltage1.y, electricCar.P_limit) annotation (Line(points={{-73,10},
          {-44,10},{-44,6.2},{-37.12,6.2}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(coordinateSystem(preserveAspectRatio=false),
        graphics={Text(
          extent={{-20,-26},{106,-108}},
          textColor={28,108,200},
          fontSize=8,
          textString="Problem an der Auswahl des Controltyps über das SimCenter: der Konnektor ändert sich nicht, wenn also limit über das SimCenter ausgewählt ist,
muss erst der Konnektor lokal gewechsel werden, damit er angesclhossen werden kann 
und dann wieder aus SimCenter umgestellt werden.


Das macht auch nur dann Sinn, 
das über das SimCenter zu regeln,
wenn beide Anschlüsse connected sind
und trotzdem funktionieren.

Frage: hat die Angabe von dem ControlFactor im SimCenter irgendeine Auswirkung?
Nur wenn ein Regelungsmodell das nutzt, oder?")}),
  Documentation(info="<html>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">1. Purpose of model</span></b></p>
<p>Test environment for the electric car model.</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">3. Limits of validity </span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">4. Interfaces</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
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
<p><span style=\"font-family: MS Shell Dlg 2;\">Model created by Dorian Hoeffner, TUHH in November 2021</span></p>
</html>"),
    experiment(
      StopTime=864000,
      Interval=3600,
      __Dymola_Algorithm="Dassl"));
end CheckElectricCarWithControl;
