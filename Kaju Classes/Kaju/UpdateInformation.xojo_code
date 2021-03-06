#tag Class
Protected Class UpdateInformation
Inherits Kaju.Information
	#tag Event
		Function IsInvalid(ByRef reason As String) As Boolean
		  static rxVersion as RegEx
		  if rxVersion is nil then
		    rxVersion = new RegEx
		    rxVersion.SearchPattern = "(?mi-Us)\A\d+(\.\d+){0,2}([dab]\d+)?\z"
		  end if
		  
		  dim r as boolean
		  
		  if not r and rxVersion.Search( Version ) is nil then
		    reason = "Version must be in one of these forms: 1, 1.2, 1.2.3, 1.2d4, 1.2a4, 1.2b4, 1.2.4b4, etc."
		    r = true
		  end if
		  
		  if not r and AppName.Trim = "" then
		    reason = "Missing app name"
		    r = true
		  end if
		  
		  if not r and MacBinary <> nil and not MacBinary.IsValid then
		    reason = "Mac Binary information is not valid: " + MacBinary.InvalidReason
		    r = true
		  end if
		  
		  if not r and WindowsBinary <> nil and not WindowsBinary.IsValid then
		    reason = "Windows Binary information is not valid: " + WindowsBinary.InvalidReason
		    r = true
		  end if
		  
		  if not r and LinuxBinary <> nil and not LinuxBinary.IsValid then
		    reason = "Linux Binary information is not valid: " + LinuxBinary.InvalidReason
		    r = true
		  end if
		  
		  return r
		End Function
	#tag EndEvent


	#tag Method, Flags = &h1000
		Sub Constructor()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(data As JSONItem)
		  Kaju.JSONToProperties( data, self )
		  
		  if data.HasName( kMacBinaryName ) then
		    MacBinary = new Kaju.BinaryInformation( false, data.Value( kMacBinaryName ) )
		  end if
		  
		  if data.HasName( kWindowsBinaryName ) then
		    WindowsBinary = new Kaju.BinaryInformation( true, data.Value( kWindowsBinaryName ) )
		  end if
		  
		  if data.HasName( kLinuxBinaryName ) then
		    LinuxBinary = new Kaju.BinaryInformation( true, data.Value( kLinuxBinaryName ) )
		  end if
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		AppName As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if mImage <> nil then
			    return mImage
			  end if
			  
			  dim url as string = ImageURL.Trim
			  
			  if url = "" then
			    return nil
			  end if
			  
			  //
			  // Get the image
			  //
			  
			  dim http as new Kaju.HTTPSSocket
			  url = http.GetRedirectAddress( url, 5 )
			  
			  dim data as string = http.Get( url, 5 )
			  
			  if data = "" then
			    return nil
			  end if
			  
			  mImage = Picture.FromData( data )
			  
			  Exception err as RuntimeException
			    mImage = nil
			    
			  Finally
			    return mImage
			    
			End Get
		#tag EndGetter
		Image As Picture
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		ImageURL As String
	#tag EndProperty

	#tag Property, Flags = &h0
		LinuxBinary As Kaju.BinaryInformation
	#tag EndProperty

	#tag Property, Flags = &h0
		MacBinary As Kaju.BinaryInformation
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mImage As Picture
	#tag EndProperty

	#tag Property, Flags = &h0
		MinimumRequiredVersion As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  dim binaryInfo as Kaju.BinaryInformation
			  
			  #if TargetMacOS then
			    binaryInfo = MacBinary
			  #elseif TargetWin32 then
			    binaryInfo = WindowsBinary
			  #else // Linux
			    binaryInfo = LinuxBinary
			  #endif
			  
			  return binaryInfo
			End Get
		#tag EndGetter
		PlatformBinary As Kaju.BinaryInformation
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		ReleaseNotes As String
	#tag EndProperty

	#tag Property, Flags = &h0
		RequiresPayment As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  static rx as RegEx
			  if rx is nil then
			    rx = new RegEx
			    rx.SearchPattern = "[dab]"
			  end if
			  
			  dim match as RegExMatch = rx.Search( Version )
			  if match is nil then
			    
			    return App.Final
			    
			  else
			    
			    select case match.SubExpressionString( 0 )
			    case "d"
			      return App.Development
			    case "a"
			      return App.Alpha
			    case "b"
			      return App.Beta
			    end
			    
			  end if
			End Get
		#tag EndGetter
		StageCode As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		UseTransparency As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		Version As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return Kaju.VersionToDouble( Version )
			End Get
		#tag EndGetter
		VersionAsDouble As Double
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		WindowsBinary As Kaju.BinaryInformation
	#tag EndProperty


	#tag Constant, Name = kLinuxBinaryName, Type = String, Dynamic = False, Default = \"LinuxBinary", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kMacBinaryName, Type = String, Dynamic = False, Default = \"MacBinary", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kWindowsBinaryName, Type = String, Dynamic = False, Default = \"WindowsBinary", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="AppName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Image"
			Group="Behavior"
			Type="Picture"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ImageURL"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsValid"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MinimumRequiredVersion"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ReleaseNotes"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RequiresPayment"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StageCode"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="UseTransparency"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Version"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="VersionAsDouble"
			Group="Behavior"
			Type="Double"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
