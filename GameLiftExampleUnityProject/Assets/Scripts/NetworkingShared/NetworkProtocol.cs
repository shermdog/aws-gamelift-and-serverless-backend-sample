﻿// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

// Helper class to serialize and deserialize messages to a network stream

using System;
using System.Net.Sockets;
using System.Collections.Generic;
using System.Runtime.Serialization.Formatters.Binary;

public class NetworkProtocol
{
    public static SimpleMessage[] Receive(TcpClient client)
    {
        try
        {
            NetworkStream stream = client.GetStream();
            var messages = new List<SimpleMessage>();
            while (stream.DataAvailable)
            {
                try
                {
                    BinaryFormatter formatter = new BinaryFormatter();
                    SimpleMessage message = formatter.Deserialize(stream) as SimpleMessage;
                    messages.Add(message);
                }
                catch (Exception e)
                {
                    System.Console.WriteLine("Error receiving a message: " + e.Message);
                    System.Console.WriteLine("Aborting the rest of the messages");
                    break;
                }
            }

            return messages.ToArray();
        }
        catch (Exception e)
        {
            System.Console.WriteLine("Error accessing message stream: " + e.Message);
        }

        return new SimpleMessage[0];
    }

    public static void Send(TcpClient client, SimpleMessage message)
    {
        try
        {
            if (client == null) return;
            NetworkStream stream = client.GetStream();
            BinaryFormatter formatter = new BinaryFormatter();
            formatter.Serialize(stream, message);
        }
        catch (Exception e)
        {
            System.Console.WriteLine("Error sending data: " + e.Message);
        }
    }
}
