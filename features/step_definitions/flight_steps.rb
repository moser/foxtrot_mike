Given /^two people and a plane$/ do
  Given 'a person named Foo Bar'
  Given 'a person named John Doe'
  Given 'a plane record:', table(%{
    | registration | D-1234 |
    | make | BF IV |
  })
end

