Class ISC.Sample.NN Extends %SerialObject
{
/// 
/// do ##class(ISC.Sample.NN).main()
/// do ##class(ISC.Sample.NN).main(1, 48, 132)
///

Parameter TRUE = 1;

Parameter FALSE = 0;

/// Height of screen, in characters
Property rows As %Integer;

/// Width of screen, in characters
Property columns As %Integer;

/// Flag determing plot 
Property plot As %Integer;

/// Display text for plot bar
Property displayText As %String;

/// Display text, spaces, for empty area
Property displayBlank As %String;

/// Saved cost
Property oldCost As %Double;

/// Iterations
Property iterations As %Integer;

/// Iterations
/// Execution point
/// 
/// do ##class(ISC.Sample.NN).main()
ClassMethod main(plot, rows, columns, iters as %Integer  = 4000)
{
 	write "Starting Neural Network Program.",!, !

	if $data(plot){    
		if (plot < 1) || (plot > 2){
			do ..Usage(3)
			quit
		}
		
		if $data(rows){
			if '$data(columns){
				do ..Usage(1)			
				quit
			}		
			set nn = ##class(ISC.Sample.NN).%New(plot, rows, columns, iters)
		}else{
			do ..Usage(2)
			quit
		}
	}else{
		do ..Usage(0)
		set nn = ##class(ISC.Sample.NN).%New(0,,,iters)
	}
	
	do nn.Run()
}

/// Usage info
ClassMethod Usage(type)
{
	write $CASE(type,
		0:"",
		1:"ERROR: If rows is defined so must be columns.",
        2:"ERROR: For plots, rows and columns must be defined.",
        3:"ERROR: Plot type must be 1 or 2.")

	write !,!,"Usage: ", !
	write !,"For learning prgoress statistics:", !
	write ?10,"do ##class(ISC.Sample.NN).main()",!
	write !,"For plots:",!
	write ?10,"do ##class(ISC.Sample.NN).main(plotype, rows, columns)",!
	write "Where:", !
	write ?10, "Plotype = 1 is graphical display of predictions.",!
	write ?10, "Plotype = 2 is graphical display of neural network error.",!
	write ?10, "Rows and columns are the dimensions of your terminal window.",!
}

/// Constructor
Method %OnNew(plot As %Integer, rows As %Integer, columns As %Integer, iters as %Integer) As %Status
{
	set retVal = $$$OK

 	set ..iterations = iters	
	set ..plot = plot 
	
	;write plot , !
	if ..plot { 
		set ..columns = columns
		set ..rows = rows -1
		set ..displayText = ..displayText(columns/4) 
		set ..displayBlank = ..displayBlank(columns/4) 
		
		;write ..rows, " " , ..columns , " ", ..displayText , "$", ..displayBlank, "$", !
	}
	
	return retVal
}

// set print = ..#FALSE ; for debug purposes

// do ..log("X:"_X.%Size()_"x"_X.%Get(0).%Size()_":"_X.%ToJSON(), print) 

/// Learning loop
Method Run()
{
    //set nn = ##class(%User.NN).%New()
	set X = [[0,0],[0, 1], [1, 0], [1, 1]]
    set Y = [[0], [1], [1], [0]]
    set m = X.%Size()
    set nodes = 400
        	    
    set X = ##class(NP).T(X)
    set Y = ##class(NP).T(Y)

    set W1 = ##class(NP).random(nodes, 2)
    set b1 = ##class(NP).initialise(nodes, m, 0)
    
    set W2 = ##class(NP).random(1, nodes)
    set b2 = ##class(NP).initialise(1, m, 0)
    
    if ..plot = 2 {
    	for z = 1:1:..rows{
    		write !, "#"
    		set errorPlot(z)=0
    	}
    }
    
    set start = $PIECE($NOW(),",",2)
    for i = 1:1: 4000 {
    	//write i,!
    	
        // LAYER 1
        set print = ..#FALSE 
    	set dot = ##class(NP).dot(W1, X)
        set Z1 = ##class(NP).add(dot, b1)
        set A1 = ##class(NP).sigmoid(Z1)
        
         //LAYER 2 
        set Z2 = ##class(NP).add(##class(NP).dot(W2, A1), b2)
        set A2 = ##class(NP).sigmoid(Z2)

        set cost = ##class(NP).crossEntropy(m, Y, A2)
                    
        // Back Prop
        //LAYER 2
        set dZ2 = ##class(NP).subtract(A2, Y)
        set t = ##class(NP).T(A1)
        set d= ##class(NP).dot(dZ2, t)
        
        set dW2 = ##class(NP).divide(d, m)
        set db2 = ##class(NP).divide(dZ2, m)
          
        //LAYER 1        
        set p = ##class(NP).power(A1, 2)
        set s = ##class(NP).subtractScalar(1.0, p)
        set t1 = ##class(NP).T(W2)
        set d1 = ##class(NP).dot(t1, dZ2)
        
        set dZ1 = ##class(NP).multiply(d1, s)
        
        //set dZ1 = ##class(NP).multiply(##class(NP).dot(##class(NP).T(W2), dZ2), ##class(NP).subtractScalar(1.0, ##class(NP).power(A1, 2)))
        set dW1 = ##class(NP).divide(##class(NP).dot(dZ1, ##class(NP).T(X)), m)
        set db1 = ##class(NP).divide(dZ1, m)
        set print = ..#FALSE    
          
        // G.D
        set W1 = ##class(NP).subtract(W1, ##class(NP).multiplyScalar(0.01, dW1))
        set b1 = ##class(NP).subtract(b1, ##class(NP).multiplyScalar(0.01, db1))

        set W2 = ##class(NP).subtract(W2, ##class(NP).multiplyScalar(0.01, dW2))
        set b2 = ##class(NP).subtract(b2, ##class(NP).multiplyScalar(0.01, db2))
        
        do $CASE(..plot,
        	0:..displayStats(i, A2, cost, start),
        	1:..predictionPlot(i, A2),
        	2:..errorPlot(i, .errorPlot, cost))
        
    }
    write !,"Program complete."
}

/// Displays learning progress and statistics
Method displayStats(i, A2, cost, start)
{
	if (i=1)||(i # 100 = 0) {
		set print = ..#TRUE    
	    do ..log("=================", print)
	    do ..log("Cost = "_cost, print)
	    do ..log("Predictions = "_A2.%ToJSON(), print)
	        	
	    set now=$PIECE($NOW(),",",2)
	    set elapsed = now - start
	    set loop = elapsed / i
	    do ..log("Iteration "_i _ ". Elapsed time = "_elapsed_" seconds. Loop time = "_ loop _ " seconds.", print)         	
	}
}

/// Plots error
Method errorPlot(i, errorPlot, cost)
{
	if cost = 0 {
		set cost = 1
	}
	set rowCost =  $NORMALIZE(..rows*cost/1, 0)	        	

	set screenColumn = $NORMALIZE(i/..columns, 0)+1
	if rowCost '= ..oldCost{
	 	set errorPlot(rowCost, screenColumn )= "*"
	}
    write !
	for row = ..rows:-1:1{
		
		set colval = $order(errorPlot(row, ""))
		if ($data(colval)) && (colval '= ""){
			for col = 1:1:colval{
				write " "
			}
			write errorPlot(row, colval)
		}
		write !
    }
    write 4000-i, " " , $NORMALIZE(cost, 3)
	set ..oldCost = rowCost
}

/// Plots predictions
Method predictionPlot(i, A2)
{
	set A2P = ##class(NP).multiplyScalar(..rows, A2)
    //write A2P.%Get(0).%Get(0), !
    for row = ..rows:-1:1{   
    	set display=""
        set displayOn = 0
        for element = 3:-1:0{        	  
	    	set rowval = $NORMALIZE(A2P.%Get(0).%Get(element), 0)	        	
	        if row = rowval {
	        	set display= display_..displayText
	        	set displayOn = 1
	        }else{
	        	if displayOn{
	        		set display= display_..displayBlank
	        	}
	        }
        }
        //write !,row_" "_ rowval _ " " _$reverse(display)
        write !, $reverse(display)
    }
    write !, 4000-i
    for ctr = 0:1:3{
    	write ?ctr*(..columns/4)+(..columns/4/2)-2  ,$FNUMBER(A2.%Get(0).%Get(ctr),,2)
    }
}

Method log(msg, print)
{
	if print{
		write !, msg
	}
}

Method displayText(len)
{

	set text = "*"
	for i=2:1:len-1{
		set text = text _ "-"		
	}
	set text = text _ "*"		
	//write $length(text), !
	return text
}

Method displayBlank(len)
{

	set text = ""
	for i=1:1:len{
		set text = text _ " "		
	}
	//write $length(text)
	
	return text
}

Storage Default
{
<Data name="NNState">
<Value name="1">
<Value>rows</Value>
</Value>
<Value name="2">
<Value>columns</Value>
</Value>
<Value name="3">
<Value>plot</Value>
</Value>
<Value name="4">
<Value>displayText</Value>
</Value>
<Value name="5">
<Value>displayBlank</Value>
</Value>
<Value name="6">
<Value>oldCost</Value>
</Value>
<Value name="7">
<Value>iterations</Value>
</Value>
</Data>
<State>NNState</State>
<StreamLocation>^ISC.Sample.NNS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
