var document = {
    "write" : function(arg){
        console.debug(arg)
    }
}
 	
function inheritRelations(obj)
	{
		var className = [];
		var prototypeChain = [];
		
		var prototype = obj;
		
		while (prototype !== null)
		{
			className.push(Object.prototype.toString.call(prototype).slice(8,-1));
			prototypeChain.push(prototype);
			prototype = Object.getPrototypeOf(prototype);
		}

		document.write("------------------原型继承顺序-----------------");
		for (var i = className.length - 1; i >= 0; i--)
		{

			document.write(className[i]);
		}
	}


 	function inheritProperties(obj)
	{
		var className = [];
		var prototypeChain = [];
		
		var prototype = obj;
		
		while (prototype !== null)
		{
			className.push(Object.prototype.toString.call(prototype).slice(8,-1));
			prototypeChain.push(prototype);
			prototype = Object.getPrototypeOf(prototype);
		}

		document.write("------------------原型继承顺序-----------------");
		for (var i = className.length - 1; i >= 0; i--)
		{

			document.write(className[i]);
		}

		for (var i = className.length - 1; i >= 0; i--)
		{

			document.write("------------------" + className[i] + "原型的属性-----------------");
			ownProperties(prototypeChain[i]);
		}
	}


function ownProperties(obj){
    var ownPropertyNames = Object.getOwnPropertyNames(obj);

    document.write("(共有" + ownPropertyNames.length + "个属性)");
    for( var i = 0 ,len = ownPropertyNames.length;i<len;i++)
    {
            if(!(i in ownPropertyNames)) 
                continue;//对于稀疏数据数组
            var propotyAttribute = "(" + (i+1) + ")" + ownPropertyNames[i] + ":" + 
                                       "                    ";
            var descriptor = Object.getOwnPropertyDescriptor(obj,ownPropertyNames[i]);
		//访问器属性
            if ( descriptor&&(descriptor.hasOwnProperty("get") || descriptor.hasOwnProperty("set")) )
            {
                if (descriptor.hasOwnProperty("get")) 
                {
                    if ((typeof descriptor.get) === "function")
                    {
                        propotyAttribute = propotyAttribute + "get--->" + (descriptor.get) + ";             ";
                    }
                    else
                    {
                        propotyAttribute = propotyAttribute + "get--->" + (typeof descriptor.get) + ";             ";
                    }
                }else{
                    propotyAttribute = propotyAttribute + "get--->" + "不存在" + ";     "; 
                }

                if (descriptor.hasOwnProperty("set")) 
                {
                    if ((typeof descriptor.get) === "function")
                    {
                        propotyAttribute = propotyAttribute + "set--->" + (descriptor.set) + ";             ";
                    }else{
                        propotyAttribute = propotyAttribute + "set--->" + (typeof descriptor.set) + ";             ";
                    }
                }else{
                    propotyAttribute = propotyAttribute + "set--->" + "不存在" + ";     "; 
                }
            }

		//数据属性
            else
            {
                if (descriptor&&descriptor.value === null) 
                {
                    propotyAttribute = propotyAttribute + "null";
                }else {
                    propotyAttribute = propotyAttribute + (typeof obj[ownPropertyNames[i]]) + "--->" + obj[ownPropertyNames[i]]; 
                }
            }
            document.write(propotyAttribute );						


	    	//document.write(ownPropertyNames[i] );
    }
}
