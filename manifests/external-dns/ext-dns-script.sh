#!/bin/bash

eksctl create iamserviceaccount --name external-dns --namespace default \
    --cluster dev-test-eks-cluster --attach-policy-arn arn:aws:iam::907299425498:policy/externalDNS-policy --approve



externalDNS-policy = 

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": "arn:aws:route53:::hostedzone/Z03363812U8ONWBTLW4I4"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "route53:ListResourceRecordSets",
                "route53:ListTagsForResource"
            ],
            "Resource": "arn:aws:route53:::hostedzone/Z03363812U8ONWBTLW4I4"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones"
            ],
            "Resource": "*"
        }
    ]
}