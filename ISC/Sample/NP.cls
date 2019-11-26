Class ISC.Sample.NP
{

   

///  Transpose of a matrix
/// 
///  @param a matrix
///  @return b = A^T
/// 
classMethod  T(a) {
	set y =  a.%Size()        
	set iter = a.%GetIterator().%GetNext(.key, .value)        
	set x = value.%Size()

    // how do you create a dynamic array of particular size
    // what is the difference between a normal array and a dynamic array
    set b = []
    for i = 0:1: x-1 {
    	set arr = []
        for j = 0:1: y-1 {
        	do arr.%Push(a.%Get(j).%Get(i))
        }
        do b.%Push(arr)
	}
    return b
}


///
/// @param a matrix
/// @param b matrix
/// @return c = a + b
///

classMethod add(a, b) {
	set m = a.%Size()
    set n = a.%Get(0).%Size()
    set c = []
        
    for i = 0:1:m-1 {
		set arr = []
        for j = 0:1:n-1{
        	do arr.%Push(a.%Get(i).%Get(j) + b.%Get(i).%Get(j))
        }
        do c.%Push(arr)
    }
    return c
}


///
/// @param a matrix
/// @param b matrix
/// @return c = a - b
///
classMethod subtract(a, b) {
	set m = a.%Size()
    set n = a.%Get(0).%Size()
    set outerArr = []

    for i = 0:1:m-1 {
    	set innerArr = []        
        for j = 0:1:n-1 {
              do innerArr.%Push(a.%Get(i).%Get(j) - b.%Get(i).%Get(j))
        }
        do outerArr.%Push(innerArr)
    }
    return outerArr
}


///
/// Element wise subtraction
///
/// @param a scalar
/// @param b matrix
/// @return c = a - b
///
classMethod subtractScalar(a, b) {
	set m = b.%Size()
    set n = b.%Get(0).%Size()
    set outerArr = []

    for i = 0:1:m-1 {
    	set innerArr = []        
        for j = 0:1:n-1 {
        	do innerArr.%Push(a - b.%Get(i).%Get(j))
        }
        do outerArr.%Push(innerArr)
	}
	return outerArr
}

///
/// Element wise multiplication
///
/// @param a matrix
/// @param x matrix
/// @return y = a * x
///

classMethod multiply(a, b) {
	set m = a.%Size()
    set n = a.%Get(0).%Size()
    
	if (b.%Size() '= m) || (b.%Get(0).%Size() '= n) {
		set mygenex = ##class(%Exception.General).%New("My multiply exception","999",, "Illegal matrix dimensions.")
        throw mygenex        
	}
    
    set outerArr = []
    for i = 0:1:m-1 {
    	set innerArr = []        
        for j = 0:1:n-1 {
              do innerArr.%Push(a.%Get(i).%Get(j) * b.%Get(i).%Get(j))
        }
        do outerArr.%Push(innerArr)
    }
    return outerArr
}

///
/// Element wise multiplication
///
/// @param a matrix
/// @param x scaler
/// @return y = a * x
///
classMethod multiplyScalar(x, a) {
	set m = a.%Size()
    set n = a.%Get(0).%Size()
        
    set outerArr = []
    for i = 0:1:m-1 {
    	set innerArr = []        
        for j = 0:1:n-1 {
              do innerArr.%Push(a.%Get(i).%Get(j) * x)
        }
        do outerArr.%Push(innerArr)
    }
    return outerArr
}


///
/// Element wise power
///
/// @param x matrix
/// @param a scaler
/// @return y
///
classMethod power(x, a) {
	set m = x.%Size()
    set n = x.%Get(0).%Size()
    set outerArr = []
    for i = 0:1:m-1 {
    	set innerArr = []        
        for j = 0:1:n-1 {
        	do innerArr.%Push($zpower(x.%Get(i).%Get(j), a))
        }
        do outerArr.%Push(innerArr)
	}
    return outerArr
}

///
/// Element wise division
///
/// @param a scaler
/// @param x matrix
/// @return x / a
///
     
classMethod divide(a, b) {
	set m = a.%Size()
    set n = a.%Get(0).%Size()
    set outerArr = []

    for i = 0:1:m-1 {
    	set innerArr = []        
        for j = 0:1:n-1 {
              do innerArr.%Push(a.%Get(i).%Get(j) / b)
        }
        do outerArr.%Push(innerArr)
    }
    return outerArr
}




///
/// @param a matrix
/// @return sigmoid of matrix a
///
classMethod sigmoid( a) {
	set m = a.%Size()
    set n = a.%Get(0).%Size()
	set z = []

       for i = 0:1:m-1 {
		set arr = []
        for j = 0:1:n-1{
        	set exp = (1.0 / (1 + $ZEXP(-a.%Get(i).%Get(j))))
                do arr.%Push(exp)
            }
            do z.%Push(arr)
        }
        return z
    }

///
/// @param m
/// @param n
/// @return random m-by-n matrix with values between 0 and 1
///
classMethod random(m, n) {
	set outerArr = []
	for i = 0:1: m-1 {
		set innerArr = []
		for j = 0:1: n-1 {
			do innerArr.%Push($random(1000)/1000)
		}
		do outerArr.%Push(innerArr)
    }
    return outerArr
}


///
/// @param a matrix
/// @param b matrix
/// @return c = a * b
///
classMethod dot( a, b) {
        set m1 = a.%Size()
        set n1 = a.%Get(0).%Size()
        set m2 = b.%Size()
        set n2 = b.%Get(0).%Size()
        if n1 '= m2 {
        	set mygenex = ##class(%Exception.General).%New("My exception","999",, "Illegal matrix dimensions.")
        	throw mygenex        
        }
        
        set c = ..initialise(m1,n2,0)

        for i = 0:1: m1-1 {
            for j = 0:1: n2-1 {
                for k = 0:1:  n1-1 {
                	set oldValue = c.%Get(i).%Get(j)
                	set value = oldValue + (a.%Get(i).%Get(k) * b.%Get(k).%Get(j))
                    do c.%Get(i).%Set(j,  value)
                }
            }
        }
        
        return c
}


///
/// @param m
/// @param n
/// @return m-by-n matrix with provided value 
///
classMethod initialise(m, n, val) {
	set outerArr = []
	for i = 0:1: m-1 {
		set innerArr = []
		for j = 0:1: n-1 {
			do innerArr.%Push(val)
		}
		do outerArr.%Push(innerArr)
    }
    return outerArr
}


/// Element wise division
///
/// @param A matrix
/// @param Y matrix
/// @param batch_size scaler
/// @return loss
///
classMethod crossEntropy( batchSize,  Y, A) {
        set m = A.%Size()
        set n = A.%Get(0).%Size()
        //double[][] z = new double[m][n];
        set outerArr = []
        for i = 0:1: m-1 {
        	set innerArr = []
        	for j = 0:1:n-1{
        		set a = A.%Get(i).%Get(j)
        		if 1-a'=0 {
        			do innerArr.%Push((Y.%Get(i).%Get(j) * $Zlog(A.%Get(i).%Get(j))) + ((1 - Y.%Get(i).%Get(j)) * $Zlog(1 - A.%Get(i).%Get(j))))
        		}else{
        			do innerArr.%Push(0)
        		}
            }
            do outerArr.%Push(innerArr)
        }

        //write !,"outerArr:"_outerArr.%Size()_"x"_outerArr.%Get(0).%Size()_":"_outerArr.%ToJSON()   

        set sum = 0
        for k = 0:1:m-1 {
            for l = 0:1: n-1 {
                set sum = sum + outerArr.%Get(k).%Get(l)
            }
        }
        return -sum / batchSize
}



}