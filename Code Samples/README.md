# Code Projects

This folder contains project code that I'm proud of.

https://github.com/DeepSeaFission/Engineering-Portfolio/blob/main/Code%20Samples/Images/Integrin%20Brownian%20Motion.mp4

## Integrin Brownian Motion Code

This was the final project for my Biomedical Engineering Computational Methods class. The objective was straightforward: simulated the brownian motion of activated and inactivated integrins. Don't worry about collisions, but do wrap any integrins that go beyond the boundaries to the corresponding side. I challenged myself with an additional constraint: to keep the code to one single loop, with no nested loops. 

I did those using complex boolean statements, such as the one below.

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

The code was able to run very quickly due to the lack of excessive loops, and I received a perfect grade for the assignment.

## Space Mission Resource Planner

In my free time, I used to play a lot of Kerbal Space Program with modifications to the game that attempt to make it as close to real life as possible, including managing CO2 generation, oxygen consumption, astronaut stress, and N-body physics. To optimize craft mass, I developed the 1859 line kerbal_resources_v2.m code. This code uses a GUI to prompt the user to input their mission paramaters and then outputs the optimal balance of resources. If the user has recently run the code, the code asks the user if they want to keep their recent parameters. Doing so still brings up the GUI, but the default parameters are overwritten by the last user settings, making it easy to make small changes. 

![KSP GUI](Images/KSP%20GUI.png)

## Image Cropping and Transparency

While working in my lab, I needed to rapidly crop and make the backgrounds transparent for hundreds of images. I developed this code to quickly do so. The code detects the color at the boundaries, then converts it to transparent pixel by pixel to avoid inadvertently making disconnected pixels of the same color transparent. This results only in the background color becoming transparent. Then, the image is cropped to content.

## Machine Learning Project

My Machine Learning class allowed the option of selecting a database of interest to us and using machine learning to see if any underlying patterns could be sussed out. I selected the UC Irvine machine learning database's (open source) child leukemia database. The code is primarily a proof-of-concept, as two important potential variables, age and weight, were left in. These two variables obviously played an outsized role in survival. However, the code stil demonstrates the application of several machine learning methods as well as proper hyperparameter selection. 
