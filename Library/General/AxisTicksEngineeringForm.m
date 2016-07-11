function [ xticks, order, spacing ] = AxisTicksEngineeringForm( xticks0 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if min(size(xticks0))>1
    [~, order] = EngineeringForm(max(abs(xticks0),[],2));
    xticks = xticks0.*repmat(10.^-order,1,size(xticks0,2));
    spacing = xticks(2)-xticks(1);
else
    [~, order] = EngineeringForm(max(abs(xticks0)));
    xticks = xticks0.*repmat(10.^-order,1,size(xticks0,2));
    spacing = xticks(2)-xticks(1);
end
end

