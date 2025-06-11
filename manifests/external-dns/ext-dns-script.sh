#!/bin/bash

eksctl create iamserviceaccount --name external-dns --namespace default \
    --cluster dev-test-eks-cluster --attach-policy-arn arn:aws:iam::000000000000:policy/externalDNS-policy --approve



externalDNS-policy = 

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": "arn:aws:route53:::hostedzone/ZZZZZZZZZZZZZZZZZZZ"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "route53:ListResourceRecordSets",
                "route53:ListTagsForResource"
            ],
            "Resource": "arn:aws:route53:::hostedzone/ZZZZZZZZZZZZZZZZZZZ"
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