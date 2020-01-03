'''
Created on 7/12/2019

@author: juan.marriaga
'''

from kafka import KafkaConsumer
import cv2
import json
import numpy as np
from _ast import If
from numpy import dtype

def main():    
    print(cv2.__version__)
    windowName="RTSPvideo"
    cv2.namedWindow(windowName)
    
    consumer = KafkaConsumer(
    'camera1',
     bootstrap_servers=['10.1.1.3:9092'],
     auto_offset_reset='latest',
     enable_auto_commit=True,
     group_id='my-group2')
    
    for msg in consumer:
        val = msg.value
        image_np = np.asarray(bytearray(val), dtype="uint8")
        
        mat = cv2.imdecode(image_np, cv2.IMREAD_COLOR);
        cv2.imshow(windowName,mat)
        cv2.waitKey(1)
    consumer.close()
    
    return

if __name__ == '__main__':
    pass
    main()
        