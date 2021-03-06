%This file is part of TEAP.
%
%TEAP is free software: you can redistribute it and/or modify
%it under the terms of the GNU General Public License as published by
%the Free Software Foundation, either version 3 of the License, or
%(at your option) any later version.
%
%TEAP is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with TEAP.  If not, see <http://www.gnu.org/licenses/>.
% 
%> @file EEG__new_empty.m
%> @brief Creates a new EEG empty signal
function Signal = EEG__new_empty()

Signal = Signal__new_empty();
Signal = Signal__set_signame(Signal, EEG__get_signame());
Signal = Signal__set_unit(Signal, 'uV'); % Matlab does not display 'µ'

