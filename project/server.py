import time 
import asyncio
import json
import logging
import sys
import aiohttp



"""
reference: https://docs.python.org/3/library/asyncio-protocol.html#tcp-echo-server-protocol   
                          my main() code follows the example code  in "18.5.4.3.2 TCP echo server protocal"
"""

portmap = {'Goloman':16340,'Hands':16341,'Holiday':16342,'Welsh':16343,'Wilkes':16344}
servertalk = {'Goloman':['Hands','Holiday','Wilkes'], 'Hands':['Goloman','Wilkes'],'Holiday':['Goloman','Welsh','Wilkes'],
        'Welsh':['Holiday'],'Wilkes':['Goloman','Hands','Holiday']}
portlist = {16340,16341,16342,16343,16344}
clientlist = {}

class ServerProtocal(asyncio.Protocol):
    def __init__(self,name,loop):
        self.name = name
        self.loop = loop
    def connection_made(self,transport):
        connectname = transport.get_extra_info('peername')
        self.transport = transport
        logging.info('connection made between {} with {}'.format(self.name,connectname))
    

    def data_received(self,data):
        try:
            result = data.decode()
        except UnicodeDecodeError:
            self.transport.write('?'.encode())
            self.transport.write(data)
            logging.info('cannot decode data received')
            return
        logging.info('receive input from {}'.format(self.transport.get_extra_info('peername')))
        result_words = result.split()
        if(len(result_words) !=4 and len(result_words)!=7):
            logging.info('number of arguments wrong')
            temp = '?'+result
            self.transport.write(temp.encode())
            return 
        if(result_words[0] != 'WHATSAT' and result_words[0]!= 'IAMAT' and result_words[0]!='AT'):
            logging.info('invalid command')
            temp = '?'+result
            self.transport.write(temp.encode())
            return
        
        commandID = result_words[0]
        senderport = self.transport.get_extra_info('peername')[1]
        if(commandID == 'IAMAT'):
            resultIAMAT = self.IAMAT_handle(result_words)
            if resultIAMAT == 'false':
                errorstr = ' '.join(result_words)
                self.responderror(errorstr,'IAMAT arguments wrong')
                return
            else:
                self.transport.write(resultIAMAT.encode())
                clientID = result_words[1]
                asyncio.ensure_future(self.flooding(resultIAMAT),loop=self.loop)
                logging.info('{} successfully handled IAMAT call from {}'.format(self.name,clientID))
                return
        elif (commandID == 'WHATSAT'):
            WHATSAT_result = self.WHATSAT_handle(result_words)
            if not WHATSAT_result:
                return
            else:
                clientID = result_words[1]
                clientINFO = clientlist[clientID]
                time_diff = time.time()-clientINFO[0]
                at_string_list = ['AT',self.name,str(time_diff),clientID,clientINFO[1],str(clientINFO[0])]
                asyncio.ensure_future(self.askGoogle(result_words,at_string_list),loop=self.loop)


        else:
            AT_result = self.AT_handle(result_words)
            if not AT_result:
                return
            else:
                newtime = float(result_words[5])
                location = result_words[4]
                clientID = result_words[3] 
                asyncio.ensure_future(self.flooding(result),loop=self.loop)


    async def askGoogle(self,words,atstring):
        location = atstring[4]
        if(location[0] == '+'):
            try:
                indexlocation = location.index('-')
            except:
                indexlocation = location.index('+',1)
        else:
            try:
                indexlocation = location.index('+')
            except:
                indexlocation = location.index('-',1)                                #add , to the location so it can be identified by google
        newlocation = location[:indexlocation]+','+ location[indexlocation:]
        radius =   int(words[2])*1000
        numberofplaces = int(words[3])
        key =  'AIzaSyDGstFR53BJYh8IaahLUmHwdc2eJxm94ko'
        at_string  = ' '.join(atstring)
        at_string  = at_string + '\n'
        async with aiohttp.ClientSession() as session:
            parameter = {'radius':str(radius),'key':key}
            async with session.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location='+newlocation,params = parameter) as resp:
                await self.googlehelper(await resp.json(),numberofplaces)
        return 

    async def googlehelper(self,data,bound):
        data['results'] = data['results'][:bound]
        data_str = json.dumps(data,indent=4,separators=(',',':'))
        data_str = data_str.rstrip('\n')
        data_str = data_str + '\n'+'\n'
        self.transport.write(data_str.encode())
        logging.info('successfully write google information')
        return
    

    async def flooding(self,floodstring):
        flood_list = []
        floodstring_list = floodstring.split()
        try:
            sendername = floodstring_list[6]
            floodstring_list[6] = self.name
        except:
            sendername = ' '
            floodstring_list.append(self.name)
        floodstring = ' '.join(floodstring_list)
        talk_list = servertalk[self.name]
        clientID = floodstring_list[3]
        temptime = float(floodstring_list[5])
        location  = floodstring_list[4]
        if(clientID not in clientlist):
            clientlist[clientID] = (temptime,location)  
        else:
            if(temptime <= clientlist[clientID][0]):
                return
            else:
                clientlist[clientID] = (temptime,location)  #if more recent, update the dictionary
            
        for x in talk_list:
            if x != sendername :
                flood_list.append(portmap[x])    #exclude sender
        for item in flood_list:
            try:
                logging.info('try to flood message {} to {} from {}'.format(floodstring,str(item),self.name))
                flood_connection  = asyncio.open_connection('127.0.0.1',item,loop=self.loop)
                (r,w) = await flood_connection
                w.write(floodstring.encode())
                await w.drain()
                w.close()
                logging.info('successfully flood to {} from {}'.format(str(item),self.name))
            except ConnectionRefusedError:
                logging.info('connection refused by {} from {}'.format(str(item),self.name))
                continue
            


    def IAMAT_handle(self,words):
        if(len(words)!=4):
            return 'false'
        clientID = words[1]
        logging.info('receive IAMAT message from {}'.format(clientID))
        location = words[2]
        newtime  = words[3]
        if not self.islocation(location):
            return 'false'
        if not self.isunixtime(newtime):
            return 'false'

        time_diff = time.time()-float(newtime)
        time_diff_str = "{0:.9f}".format(time_diff)
        resultstr = clientID + ' '+ location + ' ' + newtime
        if time_diff >=0:
            time_diff_str = '+'+time_diff_str
        resultstr = 'AT'+ ' '+ self.name + ' ' + time_diff_str + ' ' + resultstr +'\n' 
        return resultstr

    def WHATSAT_handle(self,words):        
        
        if(len(words)!=4):
            errorstr = ' '.join(words)
            self.responderror(errorstr,'number of WHATSAT arguments wrong')
            return False
        clientID = words[1]
        logging.info('receive WHATSATMAT message from {}'.format(clientID)) 
        if(clientID not in clientlist):
            errorstr = ' '.join(words)
            self.responderror(errorstr,'{} information not known for WHATSAT '.format(clientID))
            return False
       
        radius = words[2]
        amount = words[3]
        try:
            radius = float(radius)
            amount = int(amount)
        except TypeError:
            errorstr = ' '.join(words)
            self.responderror(errorstr,'WHATSAT argument wrong')
            return False
        if(radius <=0 or amount<=0 or radius >50 or amount >20):
            errorstr = ' '.join(words)
            self.responderror(errorstr,'WHATSAT argument wrong')
            return False
        return True





    def AT_handle(self,words):
        connectionport = self.transport.get_extra_info('peername')[1]
        logging.info('receive AT message from {}'.format(str(connectionport)))
        if(len(words)!=7):
            errorstr = ' '.join(words)
            self.responderror(errorstr,'number of arguments for AT wrong')
            return False
        servername = words[1]
        if(servername not in portmap):
            errorstr = ' '.join(words)
            self.responderror(errorstr,'the server that send the message is not in the list')
            return False          
        return True    



    

    def responderror(self,result,error):
        temp = '? '+ result +'\n'
        logging.info('{}'.format(error))
        self.transport.write(temp.encode())
        return
    
    #test if the location is IOS6709
    def islocation(self,location):   
        if location[0]!= '+' and location[0]!= '-':
            return False
        try:
            index = location.index('+',1)
        except ValueError:
            try: index = location.index('-',1)
            except ValueError:
                return False
        
        latitude = location[:index]
        longtitude = location[index:]
        try:
            latitude = float(latitude)
        except ValueError:
            return False
        try:
            longtitude = float(longtitude)
        except ValueError:
            return False
        return True

    #check if time is unixtime format
    def isunixtime(self,time):
        try: 
            temp = float(time)
        except ValueError:
                return False
        return True
    
def main():
    if len(sys.argv)!=2:
        print ("argument number not ok")
        return
    server_name = sys.argv[1]
    if server_name not in portmap :
        print("server not valid")
        return 
    port = portmap[server_name]
    loop = asyncio.get_event_loop()
    logging.basicConfig(filename = '{}.log'.format(server_name), level= logging.INFO)
    coro = loop.create_server(lambda:ServerProtocal(server_name,loop),'127.0.0.1',port)
    server = loop.run_until_complete(coro)

    try:
        loop.run_forever()
    except KeyboardInterrupt:
        pass

    logging.info('server {} closing'.format(server_name))
    server.close()
    loop.run_until_complete(server.wait_closed())
    logging.info('loop closing')
    loop.close()

if __name__ == '__main__':
    main()