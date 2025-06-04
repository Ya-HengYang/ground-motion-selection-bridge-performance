"""
Created on Sun Sep 15 21:58:19 2024

@author: yahen
"""


import matplotlib.pyplot as plt
import pandas as pd
import os
import numpy as np
import subprocess

filename = 'BridgeDynamicMain.tcl'


# Step 1: Read RSN and scale factor from the Excel file
# excel_file_path = r'C:\Users\yahen\OneDrive\01 Research\05 PEER 2024 Bridge Program\4SpanBridgeModel_OpenSees\GMs\CSS_OCsite.xlsx'  
# excel_file_path = r'C:\Users\yahen\OneDrive\01 Research\05 PEER 2024 Bridge Program\4SpanBridgeModel_OpenSees\GMs\CSS_SJsite.xlsx'  
excel_file_path = r'C:\Users\Ya-Heng Yang\OneDrive\01 Research\05 PEER 2024 Bridge Program\4SpanBridgeModel_OpenSees\GMs\CSS_SJsite.xlsx'  
df = pd.read_excel(excel_file_path)

# Extract RSN and scale factor columns
rsn_list = df['RSN'].tolist()  # Assuming the second column is named 'RSN'
scale_factor_list = df['Scalefactor_h'].tolist()  # Assuming the third column is named 'Scale Factor'

# Directory where the text files are stored
# directory_path = r'C:\Users\yahen\OneDrive\01 Research\05 PEER 2024 Bridge Program\4SpanBridgeModel_OpenSees\GMs\OCsite PEERNGARecords_Unscaled'
# directory_path = r'C:\Users\yahen\OneDrive\01 Research\05 PEER 2024 Bridge Program\4SpanBridgeModel_OpenSees\GMs\SJsite PEERNGARecords_Unscaled'
directory_path = r'C:\Users\Ya-Heng Yang\OneDrive\01 Research\05 PEER 2024 Bridge Program\4SpanBridgeModel_OpenSees\GMs\SJsite PEERNGARecords_Unscaled'


#%%
size = 194    # for SJ site
# size = 201    # for OC site
EDP21   = np.zeros(size)
EDP22   = np.zeros(size)
EDPmax2 = np.zeros(size)

EDP31   = np.zeros(size)
EDP32   = np.zeros(size)
EDPmax3 = np.zeros(size)

EDP41   = np.zeros(size)
EDP42   = np.zeros(size)
EDPmax4 = np.zeros(size)


# Step 2 and 3: Process each RSN and locate corresponding files ('' differet integration) 158
main_index = 0

# rsn = rsn_list[main_index]

# indices = [88]

# for rsn in rsn_list[main_index]:
for rsn in rsn_list:
# for main_index, rsn in zip(indices, [rsn_list[i] for i in indices]):
    
    # print(f"Index: {main_index}, RSN: {rsn}")  
    
    rsn_prefix = f"RSN{rsn}_"
    
    # Find the two txt files with the RSN prefix in the directory
    matched_files = [f for f in os.listdir(directory_path) if f.startswith(rsn_prefix)]
    
    if len(matched_files) == 2:
        
        index = 0
        
        for file_name in matched_files:
            file_path = os.path.join(directory_path, file_name)
            
            # Read the file and transform the format
            with open(file_path, 'r') as file:
                lines = file.readlines()
                
                # Extract DT from the header line (assumed to be the 4th line)
                header_line = lines[3]
                dt = float(header_line.split('=')[2].split()[0])
                
                # Read ground motion records starting from the fifth line
                ground_motion_data = []
                for line in lines[4:]:
                    ground_motion_data.extend([float(val) for val in line.split()])
                
                # Create two columns: Time Series and Ground Motion Record
                time_series = [i * dt for i in range(len(ground_motion_data))]
                
                # Combine into a DataFrame
                transformed_df = pd.DataFrame({
                    'Time': time_series,
                    'Ground Motion': np.multiply(ground_motion_data, scale_factor_list[main_index]) 
                })
            
            direction = file_name.split('.')[-2][-1]   
              
            if direction == 'E':
                gm1    = transformed_df['Ground Motion'].to_list()                                    
                time1  = transformed_df['Time'].to_list()
                angle1 = 0 - 60
            elif direction == 'W':
                gm1    = transformed_df['Ground Motion'].to_list()                                 
                time1  = transformed_df['Time'].to_list()
                angle1 = 180- 60
            elif direction == 'N':
                gm2    = transformed_df['Ground Motion'].to_list()
                time2  = transformed_df['Time'].to_list()
                angle2 = 90- 60
                
            elif direction == 'S':
                gm2   = transformed_df['Ground Motion'].to_list()
                time2 = transformed_df['Time'].to_list()  
                angle2 = 270- 60
                
            else:
                if index == 0:
                    gm1    = transformed_df['Ground Motion'].to_list()  
                    time1  = transformed_df['Time'].to_list()
                    angle1 = int(file_name.split('.')[-2][-3:]) - 60
                else:
                    gm2    = transformed_df['Ground Motion'].to_list()
                    time2 = transformed_df['Time'].to_list()  
                    angle2 = int(file_name.split('.')[-2][-3:]) - 60
                                                    
            index += 1
                               
        # Function to downsample a list
        def downsample_list(data, target_length):
            indices = np.linspace(0, len(data) - 1, target_length).astype(int)
            return [data[i] for i in indices]
                
        # Downsample to match the lengths
        if len(gm1) > len(gm2):
            gm1 = downsample_list(gm1, len(gm2))
            time = time2
        elif len(gm2) > len(gm1):
            gm2 = downsample_list(gm2, len(gm1)) 
            time = time1
        else:
            time = time1
        
              
        gm11 = [x * 386 for x in gm1]
        gm22 = [x * 386 for x in gm2]
       
        
        gm1 = (np.multiply(gm11,np.cos(np.radians(angle1))) + np.multiply(gm22,np.cos(np.radians(angle2)))).tolist()
        gm2 = (np.multiply(gm11,np.sin(np.radians(angle1))) + np.multiply(gm22,np.sin(np.radians(angle2)))).tolist()
        
        # plt.figure(figsize=(10, 6))
        # plt.plot(time, gm1, label='Ground Motion dir1', linewidth=1)
        # plt.plot(time, gm2, label='Ground Motion dir2', linewidth=1)
        # plt.xlabel('Time (seconds)', fontsize=14, fontname='Times New Roman')
        # plt.ylabel('Ground Motion (in/sec2)', fontsize=14, fontname='Times New Roman')
        # plt.title('Ground Motion Time Series', fontsize=14, fontname='Times New Roman')
        # plt.xticks(fontsize=14, fontname='Times New Roman')
        # plt.yticks(fontsize=14, fontname='Times New Roman')
        # plt.grid(True)
        # plt.legend(frameon=False)
        # plt.show()
             
        # Function to ensure input is always a list
        def ensure_list(value):
            return value if isinstance(value, list) else [value]
        
        # Function to format list into TCL-compatible string
        def format_for_tcl(lst):
            return " ".join(f"{x:.6g}" for x in lst)
        
        # Convert all variables to lists if necessary
        time = ensure_list(time)
        dt   = ensure_list(dt)
        gm1  = ensure_list(gm1) 
        gm2  = ensure_list(gm2)  
        
        # Open the file and write formatted content
        with open('InputString.txt', 'w') as fileID:
            fileID.write(f'set time {{{format_for_tcl(time)}}}\n')
            fileID.write(f'set dt {{{format_for_tcl(dt)}}}\n')
            fileID.write(f'set gm1 {{{format_for_tcl(gm1)}}}\n')
            fileID.write(f'set gm2 {{{format_for_tcl(gm2)}}}\n')
            fileID.write(f'source {filename}\n')
            fileID.write('exit')
        
        os.system('OpenSees.exe < InputString.txt')
        # subprocess.run(['start', 'cmd', '/k', 'OpenSees.exe < InputString.txt'], shell=True) 
          
    else:
        print(f"No matching files found or not exactly two files for RSN {rsn}")


    # Read the data from the file
    file_path = r'Data_Dynamic\Pier2D.out'
    data = pd.read_csv(file_path, sep='\s+', header=None)
        
    # Calculate the absolute max value for the second and third columns
    edp21_max = data[1].abs().max()
    edp22_max = data[2].abs().max()
    EDP2      = np.sqrt(data[1]**2 + data[2]**2)
    EDP_max2  = EDP2.max()
        
    # Store the values into the arrays
    EDP21[main_index]   = edp21_max
    EDP22[main_index]   = edp22_max
    EDPmax2[main_index] = EDP_max2
    
    # Read the data from the file
    file_path = r'Data_Dynamic\Pier3D.out'
    data = pd.read_csv(file_path, sep='\s+', header=None)
        
    # Calculate the absolute max value for the second and third columns
    edp31_max = data[1].abs().max()
    edp32_max = data[2].abs().max()
    EDP3      = np.sqrt(data[1]**2 + data[2]**2)
    EDP_max3  = EDP3.max()
        
    # Store the values into the arrays
    EDP31[main_index]   = edp31_max
    EDP32[main_index]   = edp32_max
    EDPmax3[main_index] = EDP_max3
    
    # Read the data from the file
    file_path = r'Data_Dynamic\Pier4D.out'
    data = pd.read_csv(file_path, sep='\s+', header=None)
        
    # Calculate the absolute max value for the second and third columns
    edp41_max = data[1].abs().max()
    edp42_max = data[2].abs().max()
    EDP4      = np.sqrt(data[1]**2 + data[2]**2)
    EDP_max4  = EDP4.max()
        
    # Store the values into the arrays
    EDP41[main_index]   = edp41_max
    EDP42[main_index]   = edp42_max
    EDPmax4[main_index] = EDP_max4
    
    main_index += 1
    print(main_index)
    
# np.savez('EDPs_OCsite.npz', EDP21=EDP21, EDP22=EDP22, EDP31=EDP31, EDP32=EDP32, EDP41=EDP41, EDP42=EDP42, EDPmax2=EDPmax2, EDPmax3=EDPmax3, EDPmax4=EDPmax4)
np.savez('EDPs_SJsite.npz', EDP21=EDP21, EDP22=EDP22, EDP31=EDP31, EDP32=EDP32, EDP41=EDP41, EDP42=EDP42, EDPmax2=EDPmax2, EDPmax3=EDPmax3, EDPmax4=EDPmax4)

data = np.load('EDPs_SJsite.npz')

# Access the arrays stored inside the .npz file
EDP21 = data['EDP21']
EDP22 = data['EDP22']
EDP31 = data['EDP31']
EDP32 = data['EDP32']
EDP41 = data['EDP41']
EDP42 = data['EDP42']
EDPmax2=data['EDPmax2']
EDPmax3=data['EDPmax3']
EDPmax4=data['EDPmax4']

EDPmax2p = EDPmax2 / 25.81/12*100
EDPmax3p = EDPmax3 / 24.636/12*100
EDPmax4p = EDPmax4 / 22.165/12*100
