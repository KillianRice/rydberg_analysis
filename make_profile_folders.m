function [] = make_profile_folders()

mkdir ./profiles;

for i = 31:2:45
    folder = strcat('./profiles/n',num2str(i));
    mkdir(folder)
end

end