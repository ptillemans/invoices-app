# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Organization.create([
                        {name: 'Fremach Financial Services',
                         default_approver: 'pjot',
                         backends: ['jira']
                        },
                        {name: 'Fremach International',
                         default_approver: 'pjot',
                         backends: ['jira'],
                        },
                        {name: 'Fremach Izegem',
                         default_approver: 'pfdj',
                         backends: ['jira'],
                        },
                        {name: 'Fremach Plastics',
                         default_approver: 'pjot',
                         backends: ['jira'],
                        }
                    ])

User.create([{username: 'ronny',
                 admin: 'true',
                 password: 'welcome'
                }])
