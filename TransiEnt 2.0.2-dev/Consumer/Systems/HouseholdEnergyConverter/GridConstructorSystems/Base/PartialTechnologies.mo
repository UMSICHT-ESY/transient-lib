﻿within TransiEnt.Consumer.Systems.HouseholdEnergyConverter.GridConstructorSystems.Base;
partial model PartialTechnologies

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
// Gas- und Wärme-Institut Essen						  //
// and                                                                            //
// XRG Simulation GmbH (Hamburg, Germany).                                        //
//________________________________________________________________________________//

  // _____________________________________________
  //
  //          Imports and Class Hierarchy
  // _____________________________________________

  outer TransiEnt.SimCenter simCenter;
  outer TransiEnt.ModelStatistics modelStatistics;

  // _____________________________________________
  //
  //                   Parameters
  // _____________________________________________

  // Every  parameter activates(=1) or deactivates(=0) a certain technology in an extended Systems model.
  // The assignment of the booleans to the specific technologies is carried out in the respective Systems model
  // Approach is needed for the possibility of vector assignment in the Grid_Constructor model

// _____________________________________________
  //
  //          Parameters
  // _____________________________________________

  parameter Boolean el_grid annotation(HideResult=true);
  parameter Boolean gas_grid annotation(HideResult=true);
  parameter Boolean DHN annotation(HideResult=true);

protected
  parameter TILMedia.VLEFluidTypes.BaseVLEFluid   medium= simCenter.fluid1 if DHN "Heat carrier medium for district heat, if applicable"
                         annotation(choicesAllMatching, Dialog(group="Fluid Definition"));

  parameter TILMedia.VLEFluidTypes.BaseVLEFluid   medium1= simCenter.gasModel1 "Medium to be used for fuel gas, if applicable"
             annotation(choicesAllMatching, Dialog(group="Fluid Definition"));



  // _____________________________________________
  //
  //                   Interfaces
  // _____________________________________________

  // Switch off physical connectors which are not needed (e.g. no gas consuming technologies --> No gas connection to the grid is needed -->  Gas Port is switched off)
  // Approach is needed to allow for a successful compilation of the simulation

public
  TransiEnt.Basics.Interfaces.Combined.HouseholdDemandIn demand "Electricity, space heating, water heating" annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=270,
        origin={0,100})));
  TransiEnt.Basics.Interfaces.Thermal.FluidPortIn waterPortIn(Medium=medium)  if DHN annotation (Placement(transformation(extent={{-30,-108},{-10,-88}})));
  TransiEnt.Basics.Interfaces.Thermal.FluidPortOut waterPortOut(Medium=medium)  if DHN annotation (Placement(transformation(extent={{10,-108},{30,-88}})));
  TransiEnt.Basics.Interfaces.Electrical.ApparentPowerPort    epp      if el_grid annotation (Placement(transformation(extent={{-90,-108},{-70,-88}})));
  TransiEnt.Basics.Interfaces.Gas.RealGasPortIn gasPortIn(Medium=medium1)  if gas_grid annotation (Placement(transformation(extent={{70,-106},{90,-86}})));


equation

  annotation (
    HideResult=true,
    choices(__Dymola_checkBox=true),
    Placement(transformation(extent={{-30,-108},{-10,-88}})),
    Placement(transformation(extent={{10,-108},{30,-88}})),
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={Rectangle(
          extent={{-100,82},{100,-96}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid)}),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    defaultComponentName="systems",
    Documentation(info="<html>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">1. Purpose of model</span></b></p>
<p>Base Class of the Systems models for the GridConstructor</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">2. Level of detail, physical effects considered, and physical insight</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">3. Limits of validity </span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">4. Interfaces</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">5. Nomenclature</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">(no remarks)</span></p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">6. Governing Equations</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">7. Remarks for Usage</span></b> </p>
<p>(no remarks)</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">8. Validation</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">9. References</span></b></p>
<p>(no remarks)</p>
<p><b><span style=\"font-family: MS Shell Dlg 2; color: #008000;\">10. Version History</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Model created during IntegraNet I </span></p>
</html>"));
end PartialTechnologies;
