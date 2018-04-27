#!/usr/bin/env python
# coding=utf-8
from __future__ import division  # required in Python 2.7

import math
# import pygame
import random
from operator import itemgetter

from modules.constants import *
import numpy as mat

class Boid(pygame.sprite.DirtySprite):
    
    local_x = 0;
    local_y = 0;
    local_z = 0;
    v_x = 0;
    v_y = 0;
    v_z = 0; 
    def __init__(self, x, y,z, cohesion_weight, alignment_weight, separation_weight,
                 obstacle_avoidance_weight, goal_weight, field_of_view, max_velocity, image):
        # super(Boid, self).__init__()
        pygame.sprite.DirtySprite.__init__(self)

        # Load image as sprite
        self.image = pygame.image.load(image).convert_alpha()

        # Fetch the rectangle object that has the dimensions of the image
        self.rect = self.image.get_rect()

        # Coordinates
        self.local_x = x
        self.local_y = y
        self.local_z = z
        # print ("In INIT " + str(self.local_x) + " " + str(self.local_y) + " " + str(self.local_z))
        self.rect.x = x
        self.rect.y = y

        #print (self.real_x)
        v_x = random.randint(1, 10) / 10.0
        v_y = random.randint(1, 10) / 10.0
        v_z = random.randint(1, 10) / 10.0
        self.velocityX = v_x
        self.velocityY = v_y

        # === Attributes ===

        # Weights
        self.cohesion_weight = cohesion_weight
        self.alignment_weight = alignment_weight
        self.separation_weight = separation_weight
        self.obstacle_avoidance_weight = obstacle_avoidance_weight
        self.goal_weight = goal_weight

        self.field_of_view = field_of_view
        self.max_velocity = max_velocity

    def distance(self, entity, obstacle):
        """Return the distance from another boid"""

        if obstacle:
            dist_x = self.rect.x - entity.real_x
            dist_y = self.rect.y - entity.real_y

        else:
            # dist_x = self.rect.x - entity.rect.x
            # dist_y = self.rect.y - entity.rect.y
            dist_x = self.local_x - entity.local_x
            dist_y = self.local_y - entity.local_y
            dist_z = self.local_z - entity.local_z
        # return math.sqrt(dist_x * dist_x + dist_y * dist_y)

        return math.sqrt(dist_x * dist_x + dist_y * dist_y + dist_z * dist_z)

    def cohesion(self, boid_list):
        """Move closer to a set of boid_list"""

        if len(boid_list) < 1:
            return

        # calculate the average distances from the other prey_list
        average_x = 0
        average_y = 0
        average_z = 0
        for boid in boid_list:
            # if boid.rect.x == self.rect.x and boid.rect.y == self.rect.y:
            #     continue
            if boid.local_x == self.local_x and boid.local_y == self.local_y and boid.local_z == self.local_z:
                continue

            # average_x += (self.rect.x - boid.rect.x)
            # average_y += (self.rect.y - boid.rect.y)
            average_x += (self.local_x - boid.local_x)
            average_y += (self.local_y - boid.local_y)
            average_z += (self.local_z - boid.local_z)

        average_x /= len(boid_list)
        average_y /= len(boid_list)
        average_z /= len(boid_list)
        # set our velocity towards the others
        # self.velocityX -= (average_x / self.cohesion_weight)
        # self.velocityY -= (average_y / self.cohesion_weight)
        self.v_x -= (average_x / self.cohesion_weight)
        self.v_y -= (average_y / self.cohesion_weight)
        self.v_z -= (average_z / self.cohesion_weight)
        

    def alignment(self, boid_list):
        """Move with a set of boid_list"""

        if len(boid_list) < 1:
            return

        # calculate the average velocities of the other prey_list
        average_x = 0
        average_y = 0
        average_z = 0
        
        for boid in boid_list:
            # average_x += boid.velocityX
            # average_y += boid.velocityY
            average_x += boid.v_x
            average_y += boid.v_y
            average_z += boid.v_z

        average_x /= len(boid_list)
        average_y /= len(boid_list)
        average_z /= len(boid_list)

        # set our velocity towards the others
        self.v_x += (average_x / self.alignment_weight)
        self.v_y += (average_y / self.alignment_weight)
        self.v_z += (average_z / self.alignment_weight)

        # self.velocityX += (average_x / self.alignment_weight)
        # self.velocityY += (average_x / self.alignment_weight)

    def separation(self, boid_list, min_distance):
        """Move away from a set of boid_list. This avoids crowding"""

        if len(boid_list) < 1:
            return

        distance_x = 0
        distance_y = 0
        distance_z = 0
        num_close = 0

        for boid in boid_list:
            distance = self.distance(boid, False)

            if distance < min_distance:
                num_close += 1
                xdiff = (self.local_x - boid.local_x)
                ydiff = (self.local_y - boid.local_y)
                zdiff = (self.local_z - boid.local_z)

                if xdiff >= 0:
                    xdiff = math.sqrt(min_distance) - xdiff
                elif xdiff < 0:
                    xdiff = -math.sqrt(min_distance) - xdiff

                if ydiff >= 0:
                    ydiff = math.sqrt(min_distance) - ydiff
                elif ydiff < 0:
                    ydiff = -math.sqrt(min_distance) - ydiff

                if zdiff >= 0:
                    zdiff = math.sqrt(min_distance) - zdiff
                elif zdiff < 0:
                    zdiff = -math.sqrt(min_distance) - zdiff

                distance_x += xdiff
                distance_y += ydiff
                distance_z += zdiff

        if num_close == 0:
            return
        self.v_x -= distance_x / self.separation_weight
        self.v_y -= distance_y / self.separation_weight
        self.v_z -= distance_z / self.separation_weight

        # self.velocityX -= distance_x / self.separation_weight
        # self.velocityY -= distance_y / self.separation_weight

    def obstacle_avoidance(self, obstacle):
        """Avoid obstacles"""
        # Avoid collision with obstacles at all cost
        if self.distance(obstacle, True) < 45:
            self.velocityX = -1 * (obstacle.real_x - self.rect.x)
            self.velocityY = -1 * (obstacle.real_y - self.rect.y)
        
        else:
            self.velocityX += -1 * (obstacle.real_x - self.rect.x) / self.obstacle_avoidance_weight
            self.velocityY += -1 * (obstacle.real_y - self.rect.y) / self.obstacle_avoidance_weight

    def goal(self, mouse_x, mouse_y):
        """Seek goal"""
        self.velocityX += (mouse_x - self.rect.x) / self.goal_weight
        self.velocityY += (mouse_y - self.rect.y) / self.goal_weight

    def attack(self, target_list):
        """Predatory behavior"""
        if len(target_list) < 1:
            self.go_to_middle()
            return

        # Calculate the center of mass of target_list
        target_ids = []
        average_x = 0
        average_y = 0
        for target in target_list:
            average_x += target.rect.x
            average_y += target.rect.y

        average_x /= len(target_list)
        average_y /= len(target_list)

        # Create a 2d array containing all nearby prey and their distance from the center of mass
        for target in target_list:
            dist_x = average_x - target.rect.x
            dist_y = average_y - target.rect.y
            distance = math.sqrt(dist_x * dist_x + dist_y * dist_y)
            target_ids.append([target, distance])

        # Create an array holding the prey furthest from the center of mass of its flock
        target_id = sorted(target_ids, key=itemgetter(0))
        del target_ids

        # Set vector on intercept toward where the prey the furthest from us is going
        self.velocityX += ((target_id[0][0].rect.x +
                            (target_id[0][0].velocityX * 2)) - self.rect.x) / self.goal_weight
        self.velocityY += ((target_id[0][0].rect.y +
                            (target_id[0][0].velocityY * 2)) - self.rect.y) / self.goal_weight

        del target_id

    def flee(self, predator):
        """Prey behavior, avoid the predators"""
        self.velocityX += -(((predator.rect.x + (2 * predator.velocityX)) - self.rect.x) /
                            self.obstacle_avoidance_weight) * random.randint(1, 2)
        self.velocityY += -(((predator.rect.y + (2 * predator.velocityY)) - self.rect.y) /
                            self.obstacle_avoidance_weight) * random.randint(1, 2)

    def go_to_middle(self):
        self.v_x += (SCREEN_WIDTH / 2 - self.local_x) / 150
        self.v_y += (SCREEN_HEIGHT / 2 - self.local_y) / 150
        self.v_z += (SCREEN_HEIGHT / 2 - self.local_z) / 150

        # self.velocityX += (SCREEN_WIDTH / 2 - self.rect.x) / 150
        # self.velocityY += (SCREEN_HEIGHT / 2 - self.rect.y) / 150

    def update(self, wrap):
        """Perform actual movement based on our velocity"""
        if wrap:
            # If we leave the screen we reappear on the other side.
            if self.rect.x < 0 and self.velocityX < 0:
                self.rect.x = SCREEN_WIDTH
            if self.rect.x > SCREEN_WIDTH and self.velocityX > 0:
                self.rect.x = 0
            if self.rect.y < 0 and self.velocityY < 0:
                self.rect.y = SCREEN_HEIGHT
            if self.rect.y > SCREEN_HEIGHT and self.velocityY > 0:
                self.rect.y = 0

        else:
            #ensure they stay within the screen space
            #if we rebound we can lose some of our velocity
            if self.local_x < 0 and self.v_x < 0:
                self.v_x = -self.v_x * random.random()
            if self.local_x > SCREEN_WIDTH - 100 and self.v_x > 0:
                self.v_x = -self.v_x * random.random()
            if self.local_y < 0 and self.v_y < 0:
                self.v_y = -self.v_y * random.random()
            if self.local_y > SCREEN_HEIGHT - 100 and self.v_y > 0:
                self.v_y = -self.v_y * random.random()
            if self.local_z < 0 and self.v_z < 0:
                self.v_z = -self.v_z * random.random()
            if self.local_z > SCREEN_HEIGHT - 100 and self.v_z > 0:
                self.v_z = -self.v_z * random.random()

            # Initiate random movement if there is a standstill
            if abs(math.sqrt(self.v_x**2 + self.v_y**2 + self.v_z**2))< 2:
                self.go_to_middle()

        #Obey speed limit
        if abs(self.v_x) > self.max_velocity or abs(self.v_y) > self.max_velocity or abs(self.v_z) > self.max_velocity:
            scale_factor = self.max_velocity / max(abs(self.v_x), abs(self.v_y), abs(self.v_z))
            self.v_x *= scale_factor
            self.v_y *= scale_factor
            self.v_z *= scale_factor

        self.local_x += self.v_x/10
        self.local_y += self.v_y/10
        self.local_z += self.v_z/10
        direction = [1,1,1]
        u = direction[0]*direction[0] + direction[1]*direction[1] + direction[2]*direction[2];
       	u_x = direction[0] / math.sqrt(u);
       	u_y = direction[1] / math.sqrt(u);
       	u_z = direction[2] / math.sqrt(u);
        a = direction[0];
        b = direction[1];
        c = direction[2];
        s2 = (a*a) + (b*b) + (c*c);
        s = math.sqrt(s2);
        costheta = c / s;
        theta = math.acos(costheta)
        cosx = math.cos(theta)
        sinx = math.sin(theta)
     #   	MatrixXd R(3,3);
	    # R(0,0) = cosx + (u_x*u_x)*(1-cosx);
	    # R(1,0) = u_y*u_x*(1-cosx) - u_z*sinx;
	    # R(0,1) = u_y*u_x*(1-cosx) + u_z*sinx;
	    # R(1,1) = cosx + (u_y*u_y)*(1-cosx);
	    # R(0,2) = u_z*u_x*(1-cosx) - u_y*sinx;
	    # R(2,0) = u_z*u_x*(1-cosx) + u_y*sinx;
	    # R(2,1) = u_z*u_y*(1-cosx) - u_x*sinx;
	    # R(1,2) = u_z*u_y*(1-cosx) + u_x*sinx;
	    # R(2,2) = cosx + (u_z*u_z)*(1-cosx);

	    # take a 3x3 matrix
        A = [[cosx + (u_x*u_x)*(1-cosx), u_y*u_x*(1-cosx) + u_z*sinx, u_z*u_x*(1-cosx) - u_y*sinx],
		    [u_y*u_x*(1-cosx) - u_z*sinx, cosx + (u_y*u_y)*(1-cosx), u_z*u_y*(1-cosx) + u_x*sinx],
		    [u_z*u_x*(1-cosx) + u_y*sinx, u_z*u_y*(1-cosx) - u_x*sinx, cosx + (u_z*u_z)*(1-cosx)]]
		 
		# take a 3x4 matrix    
        B = [[self.local_x],
		    [self.local_y],
		    [self.local_z]]
		     
        result = [[0],
		        [0],
		        [0]]
		 
		# iterating by row of A
        for i in range(len(A)):
		 
		    # iterating by coloum by B
            for j in range(len(B[0])):
		 
		        # iterating by rows of B
                for k in range(len(B)):
                    result[i][j] += A[i][k] * B[k][j]
		 
        # for r in result:
        #     print(r)
	    # b = mat.matrix([[5, 6, 7], [4, 6]])
        
	    # MatrixXd p(3,1);
	    # p(0,0) = x;
	    # p(1,0) = y;
	    # p(2,0) = z;
	    
	    # MatrixXd P = R*p;

	    # x = P(0,0);
	    # y = P(1,0);
	    # z = P(2,0);

        # b = mat.matrix([[5, 6, 7], [4, 6]])
        
        
        # print ("In update " + str(self.local_x) + " " + str(self.local_y) + " " + str(self.local_z))
        self.rect.x = result[0][0]
        self.rect.y = result[1][0]

        # Since the boids should always be moving, we don't have to worry about whether or not they have a dirty rect
        self.dirty = 1
