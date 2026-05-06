% Code by Jordan Langford for BME 3301 Final Project, 24Apr23
clear,clc,
close all,

% I challenged myself to write this with no loops other than the main
% update loop. I apologize if that makes some of the code difficult to
% understand. I tried my best to explain it in the comments. Also,
% excluding formatting for ease of use and comments, I managed to do the
% whole thing in about 50 lines of code, which is neat.

% For tracking individual ligands and verifying they only move when
% inactive, I recommend about 25 ligands be simulated. The program easily
% handles several hundred, but it becomes difficult to distinguish and
% track individual ligands.

%% Domain establishment and variable definition

domain_radius = 50;    % establishes radius, in nm

% provides a visual representation of domain

simulation = figure;                                            % names our figure "simulation"
viscircles([0,0],domain_radius,'Color','k','LineWidth',1);      % draws a circle centered at x=0, y=0, with radius 50, in nm
axis equal                          % sets axes to be equal to preserve circular nature, instead of displaying an oval

% variable definitions

Pa_activation_probability = rand;                                   % probability of integrin activation, unitless
F_integrin_ligand_bond_force = rand*10;                             % integrin/ligand bond force, in...
Pub_unbinding_probability = 1/(1.5*F_integrin_ligand_bond_force);   % probability of unbinding from a ligand, unitless

%% Integrin initialization
% This section takes an input number and generates a set of (input number)
% of integrins at randomized positions, all beginning unbound and inactive.

N_number_of_integrins = input("How many integrins should be simulated? Input: ");

tic

coordinates_and_states = initialization(domain_radius,N_number_of_integrins);  
% uses intialization function to generate N x 4 matrix of format 
% [x-coord,y-coord,0,0] the last two columns are boolean falses
% representing the activation state and whether they are attached to ligands

%% Simulation
% This section updates the positions and activated/bound states for an
% input number of iterations. The max_position_change constrains the
% position change to a specified amount to avoid dramatic position changes.

max_position_change = input("Input the max displacement allowed in nm: ");
number_of_iterations = input("How many iterations? Maximum 500 >> ");
number_of_iterations = (not(number_of_iterations > 500)*number_of_iterations) + 500*(number_of_iterations > 500);
% this is just a way of ensuring the max iterations don't exceed 500, but
% without loops. Takes the inverse of a logical operation checking if 500
% is exceeded (0 if exceeded, 1 if not) and multiplies it by the input. If
% exceeded, this part becomes zero. Then adds 500 times the logical output
% once again asking if the value is exceeded, but not inverted.

hold on

inactive_ligands = coordinates_and_states(coordinates_and_states(:,3)==0,:); 
active_ligands = coordinates_and_states(coordinates_and_states(:,3)==1,:);

% these lines extract the respective rows for inactive or active ligands in
% order to have two seperate plots for ease of color assignment.

inactive_points = scatter(inactive_ligands(:,1),inactive_ligands(:,2),'g','filled');
active_points = scatter(active_ligands(:,1),active_ligands(:,2),'r','filled');

movie_frames = struct('cdata',cell(1,number_of_iterations),'colormap',cell(1,number_of_iterations));

for n = 1:number_of_iterations
    coordinates_and_states = position_update(coordinates_and_states,max_position_change);
    % This function shifts the positions of the integrins that aren't bound.
    coordinates_and_states = activation_and_ligand_binding_reverse(N_number_of_integrins,Pa_activation_probability,Pub_unbinding_probability,coordinates_and_states);
    % This function updates the bound and activated states

    coordinate_excess_r_and_theta = [
        (sqrt(coordinates_and_states(:,1).^2 + coordinates_and_states(:,2).^2) - domain_radius) .* (sqrt(coordinates_and_states(:,1).^2 + coordinates_and_states(:,2).^2) > domain_radius)...
        (coordinates_and_states(:,2)./abs(coordinates_and_states(:,2)) .* acos(coordinates_and_states(:,1) ./ sqrt(coordinates_and_states(:,1).^2 + coordinates_and_states(:,2).^2)))
        ];

    % this section generates an excess r, the value by which the input
    % radius has been exceeded, by finding the magnitude of the radius of
    % each row and subtracting the radius from it, then multiplying by the
    % logical result of asking if the radius has been exceeded. This
    % produces an excess r of 0 for values less than the radius.
    % Then, theta is calculated via the arc cosine method. Since theta's
    % formulation is dependent on whether or not y is positive, the first
    % term extracts the sign of the y coordinates and multiplies by the
    % sign.

    coordinates_and_states(:,[1,2]) = [
        (coordinates_and_states(:,1) .* (sqrt(coordinates_and_states(:,1).^2 + coordinates_and_states(:,2).^2) <= domain_radius) + coordinates_and_states(:,1) .* (-1) .* (sqrt(coordinates_and_states(:,1).^2 + coordinates_and_states(:,2).^2) > domain_radius)) + coordinate_excess_r_and_theta(:,1) .* cos(coordinate_excess_r_and_theta(:,2))...
        (coordinates_and_states(:,2) .* (sqrt(coordinates_and_states(:,1).^2 + coordinates_and_states(:,2).^2) <= domain_radius) + coordinates_and_states(:,2) .* (-1) .* (sqrt(coordinates_and_states(:,1).^2 + coordinates_and_states(:,2).^2) > domain_radius)) + coordinate_excess_r_and_theta(:,1) .* sin(coordinate_excess_r_and_theta(:,2))
        ];

    % this section adjusts coordinates by converting the excess values from
    % polar to cartesian and summing them with the original values)

    inactive_ligands = coordinates_and_states(coordinates_and_states(:,3)==0,:); 
    active_ligands = coordinates_and_states(coordinates_and_states(:,3)==1,:);

    inactive_points.XData = inactive_ligands(:,1);
    inactive_points.YData = inactive_ligands(:,2);
    active_points.XData = active_ligands(:,1);
    active_points.YData = active_ligands(:,2);
    drawnow limitrate
    movie_frames(n) = getframe;
end

toc

movie(movie_frames,1,10)

%% Functions

function output = initialization(domain_radius,sample_number)

% This function takes the circular radius of a radially defined domain
% and a number of samples and produces an and x and y position for the 
% desired number of samples, as well as defining two states as false
% (column 3 and 4 of the output)
% domain_radius = the desired radius of the 

% as demanded by the problem, I start with radius and theta.
% The two are assembled in an n x 2 matrix, with r as the first random
% number column in a range of 0 to the input radius, and theta as the
% second column, also a random number, but of range 0-360 

r_thetas = [domain_radius*rand([sample_number,1]),360*rand([sample_number,1])];

x_ys = [r_thetas(:,1).*cos(r_thetas(:,2)),r_thetas(:,1).*sin(r_thetas(:,2)),zeros(sample_number,2)];

output = x_ys;

end



function output_matrix = position_update(input_matrix,max_step)

% takes in a matrix of the format
% [x-pos,y-pos,activation state, bound state]
% and outputs an updated version, slightly moving
% all unbound specimens.
% input_matrix = the matrix to be updated
% max_step = the maximum change in position, distance

sample_number = size(input_matrix,1);                                                     % measures the number of input rows

adjustment_r_theta = [max_step*rand([sample_number,1]),360*rand([sample_number,1])];    % generates a displacement magnitude and direction
                                                                                            % in r-theta format

adjustment_x_y = [
    adjustment_r_theta(:,1).*cos(adjustment_r_theta(:,2)).*not(input_matrix(:,4))...  % x value
    adjustment_r_theta(:,1).*sin(adjustment_r_theta(:,2)).*not(input_matrix(:,4))...  % y value
    zeros(sample_number,2)                                                            % ligand states
    ];

% This one's complicated. The displacements are converted to x and y as
% before, but crucially, they are then multiplied by the INVERSE (via the
% not function) of the value in the fourth column of the input matrix.
% Since 0 = unbound, a value of 0 allows movement. By multiplying by the
% logical inverse, no motion is applied to a row when the fourth column of
% that row equals logical one, which would output a zero through the not
% function.

output_matrix = input_matrix + adjustment_x_y;

% more or less self-explanatory, sums input with the adjustment.

end



function output_matrix = activation_and_ligand_binding(sample_number,activation_probability,input_matrix)

% This function takes an input number of samples
% (redundant with my arrangement, but the project says
% to), the activation probability Pa, and the activation
% and ligand-bound status of each integrin (provided via
% the input matrix) in order to assess and shift those
% states as applicable.
% sample_number = the number of ligands being assessed
% activation_probability = the probability of a ligand
%                          changing state
% input matrix = the matrix containing the current states
%                of the ligands, with activation state 
%                being in column 3 and bound state being 
%                in column 4 using logical values.

bound_ligands = [zeros(sample_number,2),input_matrix(:,[3,4])];
% extracts which ligands are already bound for later re-addition to matrix
% to conserve their bound status.

probability_rolls = rand(sample_number,1).*not(input_matrix(:,4));

% this produces an series of random probability rolls. The second term, the
% inverse of the fourth column of the input matrix, causes all already
% bound ligands to produce a roll of 0, while all unbound ligands produce a
% multiplier of one, applied to their random roll.

output_matrix = input_matrix;
output_matrix(:,[3,4]) = [(probability_rolls > activation_probability),(probability_rolls > activation_probability)];
output_matrix = output_matrix + bound_ligands;

% another conceptually challenging operation. For the third and fourth
% columns, which represent the activation and bound state of each ligand,
% this operation replaces the old value with a new value equivalent to the
% logical output of whether or not that ligand successfully rolled higher
% than the probability of activation. Since the prior operation produced
% rolls of zero for all active ligands, this operation only applies to
% inactive ligands. As this logical operation produces zeros for all bound
% ligands, the final operation adds back in logical ones to all bound
% ligands to retain their bound status.

end



function output_matrix = activation_and_ligand_binding_reverse(sample_number,activation_probability,inactivation_probability,input_matrix)

% This function takes an input number of samples
% (redundant with my arrangement, but the project says
% to), the activation probability Pa, and the activation
% and ligand-bound status of each integrin (provided via
% the input matrix) in order to assess and shift those
% states as applicable.
% sample_number = the number of ligands being assessed
% activation_probability = the probability of a ligand
%                          changing state
% input matrix = the matrix containing the current states
%                of the ligands, with activation state 
%                being in column 3 and bound state being 
%                in column 4 using logical values.

bound_ligands = [input_matrix(:,4)];
% extracts which ligands are already bound for later re-addition to matrix
% to conserve their bound status.

turn_on_probability_rolls = rand(sample_number,1).*not(input_matrix(:,4));
turn_on_probability_rolls = turn_on_probability_rolls + bound_ligands;

% this produces an series of random probability rolls. The second term, the
% inverse of the fourth column of the input matrix, applies the random
% multiplier ONLY to not already on ligands (ligands whose inverse logical
% value = 1). Finally, already "on" ligands are added back in to ensure
% they are greater than or equal to activation probability, preventing the
% later equation from outputting a logical one that might get summed with
% the later logical one from the ligand remaining on.

turn_off_probability_rolls = rand(sample_number,1).*input_matrix(:,4);

% produces a similar matrix, but only for currently on ligands.

newly_on_ligands = zeros(sample_number,2);
newly_on_ligands(:,[1,2]) = [(turn_on_probability_rolls < activation_probability),(turn_on_probability_rolls < activation_probability)];

% another conceptually challenging operation. For the new first and second
% columns, which represent the activation and bound state of each ligand,
% this operation outputs a value per ligand/row equivalent to the
% logical output of whether or not that ligand successfully rolled higher
% than the probability of activation. Since the prior operation produced
% rolls of zero for all active ligands, this operation only applies to
% inactive ligands. As this logical operation produces zeros for all bound
% ligands, the final output is zeros for all already active ligands, zeros
% for ligands that didn't roll high enough, and ones for ligands that did
% roll high enough.

maintaining_on_and_newly_off_ligands = zeros(sample_number,2);
maintaining_on_and_newly_off_ligands(:,[1,2]) = [(turn_off_probability_rolls > inactivation_probability),(turn_off_probability_rolls > inactivation_probability)];

% similar to previous operation, but takes input states and multiplies by
% the logical result of asking if the turn off roll was higher than the
% inactivation probability. This produces a zero when the roll is lower
% than the inactivation probability, a zero for all already off states, and
% a one only when rolling higher than the inactivation probability and
% already on.

total_states = newly_on_ligands + maintaining_on_and_newly_off_ligands;

% sums the two logical groups. 

output_matrix = [input_matrix(:,[1,2]),total_states];
% re-inputs positions to output, appends new state values.

end