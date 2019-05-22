# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Organization.create([
                        {name: 'Elex',
                         default_approver: 'ior',
                         backends: ['jira']
                        },
                        {name: 'Melefin',
                         default_approver: 'tbb',
                         backends: ['viiper'],
                         viiper_dir_name: 'INVOICE_SCANS_FIN',
                        },
                        {name: 'Melexis Concord',
                         default_approver: 'tbb',
                         backends: ['viiper'],
                         viiper_dir_name: 'INVOICE_SCANS_CON',
                        },
                        {name: 'Melexis Erfurt',
                         default_approver: 'tbb',
                         backends: ['viiper'],
                         viiper_dir_name: 'INVOICE_SCANS_ERF',
                        },
                        {name: 'Melexis Ieper',
                         default_approver: 'tbb',
                         backends: ['viiper'],
                         viiper_dir_name: 'INVOICE_SCANS_IEP',
                        },
                        {name: 'Melexis NL',
                         default_approver: 'tbb',
                         backends: ['viiper'],
                         viiper_dir_name: 'INVOICE_SCANS_UTR',
                        },
                        {name: 'Melexis Sofia',
                         default_approver: 'tbb',
                         backends: ['viiper'],
                         viiper_dir_name: 'INVOICE_SCANS_SOF',
                        },
                        {name: 'Melexis Technologies',
                         default_approver: 'tbb',
                         backends: ['viiper'],
                         viiper_dir_name: 'INVOICE_SCANS_BEV',
                        },
                        {name: 'Melexis Tessenderlo',
                         default_approver: 'tbb',
                         backends: ['viiper'],
                         viiper_dir_name: 'INVOICE_SCANS_TLO',
                        },
                        {name: 'Sentron AG',
                         default_approver: 'jth',
                         backends: ['viiper'],
                         viiper_dir_name: 'INVOICE_SCANS_SEN',
                        },
                        {name: 'TVLokaal',
                         default_approver: 'ior',
                         backends: ['jira']
                        },
                        {name: 'Xpeqt',
                         default_approver: 'ior',
                         backends: ['jira']
                        },
                        {name: 'Xtrion',
                         default_approver: 'ior',
                         backends: ['jira']
                        }
                    ])

User.create([
                {username: 'pti',
                 admin: 'true'
                },
                {username: 'tbb',
                 admin: 'true'
                }])


Invoice.create([
                   {
                       book_number: '1234567',
                       approver: 'tbb',
                       file_name: 'sample/12345678.pdf',
                       uploaded: 0,
                       jira_id: 'INV-12345',
                       jira_status: 'Open',
                       organization_id: 2
                   }
                ])