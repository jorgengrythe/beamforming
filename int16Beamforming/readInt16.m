%data = readInt16(M,fs,sec,fileName,desiredMicIndex,varargin)
%M is the number of mics in the array
%sec is seconds of data to read. If set to 0 the entire file is read.
%NB!!! Memory problems may occure in this case.
%desiredMicIndex is optional. If given, only data from this mike will be
%returned
function data = readInt16(M,fs,sec,fileName,desiredMicIndex,varargin)
fid = fopen(fileName,'rb');
    ST = feof(fid);

    
if nargin==4
    data=zeros(M,1);
else
    data=0;
end



if sec>0
    data=fread(fid,[M fs*sec],'int16');
    fclose all;
end

if nargin>4 && sec>0
    data=data(desiredMicIndex,:);
end



if sec==0
    
    Nt=2;
    while ST==0
        data0=fread(fid,[M fs*Nt],'int16');
        ST = feof(fid);
        
        if nargin>4
            data0=data0(desiredMicIndex,:);
        end
        
        data=[data,data0];
        
    end
end


fclose all;


