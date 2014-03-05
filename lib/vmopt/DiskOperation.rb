require 'win32ole'
require 'Win32API'
$wmi = WIN32OLE.connect("winmgmts://")

class DiskOperation

=begin
参数：无
作用：查找物理磁盘的基本信息，并打印出来
返回值：默认
=end
	def GetDiskInformation
			colItems = $wmi.ExecQuery ("select * from Win32_DiskDrive")
	        for colItem in colItems do
	        	size=colItem.size
				size=(size.to_i/1048576).to_s
	        	print "物理驱动器号:",colItem.DeviceID,"  磁盘索引:",colItem.Index,\
	        	"   接口类型:",colItem.InterfaceType,\
	        	"   磁盘容量:",size,"M\n"
	        end

		end
=begin
参数：无
作用：查找磁盘分区的基本信息，并打印出来
返回值：默认
=end
	def GetPartitionInformation
		colItems = $wmi.ExecQuery ("select * from Win32_LogicalDisk where DriveType=3")
        for colItem in colItems do
			size=colItem.size
			size=(size.to_i/1048576).to_s
			freeSpace=colItem.FreeSpace
			freeSpace=(freeSpace.to_i/1048576).to_s

        	print "逻辑驱动器号:",colItem.DeviceID," 文件系统",colItem.FileSystem,\
        	"  分区容量",size,"M   剩余容量",freeSpace,"M\n"
        end
	end
		
=begin
参数：无
功能：判断哪些磁盘没有格式化
返回值：没有格式化的磁盘索引号
=end
	def Format?
		colItems = $wmi.ExecQuery ("select * from Win32_DiskDrive")
		index = []
        for colItem in colItems do
        	if colItem.Partitions==0
        		index.push(colItem.Index)
        	end      	
        end
        return index
	end
=begin rdoc
参数：无
功能：格式化磁盘
返回值：默认
=end
	def FormatDisk()
		system("diskpart /s c:/1.txt")
			system("format /FS:NTFS /force /Q F: " )
	end
=begin	
参数：无
功能：扫描整个系统磁盘，若存在没有格式化的磁盘则进行格式化
返回值：默认	
=end
	def ChkFormatDisk
		index = Format?
		for i in index do
					colItems = $wmi.ExecQuery ("select * from Win32_DiskDrive where index=#{i}")
					for colItem in colItems do
						size=colItem.size
						size=(size.to_i/1048576).to_s
					end
					
					logicalcolItems = $wmi.ExecQuery ("select * from Win32_LogicalDisk")
					str=[]
			        for colItem in logicalcolItems do
			        	str.push(colItem.DeviceID)
			        	volumename=str.sort!.last.next
			        end

					File.open("c:/1.txt","w")do|file|
					file.puts "select disk=#{i}"
					file.puts "create partition primary size=#{size}"
					file.puts "assign letter=#{volumename}"
				end
				FormatDisk()
				#File.open("c:/1.txt","w+")
				File.delete("c:/1.txt")
		end
	end
=begin	
参数：磁盘索引号
功能：根据指定的磁盘索引号
返回值：指定的磁盘已经被格式化返回false,成功格式化返回true
=end
	def FormatDiskByIndex(index)
		colItems = $wmi.ExecQuery ("select * from Win32_DiskDrive where index=#{index}")
		for colItem in colItems do
        	if colItem.Partitions==0
        		size=colItem.size
				size=(size.to_i/1048576).to_s
        	else
        		return false
        	end
        end
        logicalcolItems = $wmi.ExecQuery ("select * from Win32_LogicalDisk")
		str=[]
        for colItem in logicalcolItems do
        	str.push(colItem.DeviceID)
        	volumename=str.sort!.last.next
        end

		File.open("c:/1.txt","w") do|file|
		file.puts "select disk=#{index}"
		file.puts "create partition primary size=#{size}"
		file.puts "assign letter=#{volumename}"
		end
		FormatDisk()
		#File.open("c:/1.txt","w+")
		File.delete("c:/1.txt")
		return true
	end 

end
